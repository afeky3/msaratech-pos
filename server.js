const express = require('express');
const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');
const https = require('https');

const app = express();
const PORT = 3001;

app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));
app.use('/media', express.static(path.join(__dirname, 'media')));

// ══════════════════════════════════════════════════════
// HELPERS
// ══════════════════════════════════════════════════════
const DATA_DIR = path.join(__dirname, 'data');

function readJSON(file) {
  const p = path.join(DATA_DIR, file);
  if (!fs.existsSync(p)) return null;
  return JSON.parse(fs.readFileSync(p, 'utf8'));
}

function writeJSON(file, data) {
  fs.writeFileSync(path.join(DATA_DIR, file), JSON.stringify(data, null, 2));
}

function refreshShopifyToken() {
  const config = readJSON('shopify-config.json');
  if (!config || !config.clientId || !config.clientSecret || !config.store) return Promise.resolve(false);

  return new Promise((resolve) => {
    const postData = JSON.stringify({
      client_id: config.clientId,
      client_secret: config.clientSecret,
      grant_type: 'client_credentials'
    });
    const parsed = new URL(`https://${config.store}/admin/oauth/access_token`);
    const options = {
      hostname: parsed.hostname,
      path: parsed.pathname,
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Content-Length': Buffer.byteLength(postData) },
      timeout: 15000
    };
    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', chunk => { data += chunk; });
      res.on('end', () => {
        try {
          const result = JSON.parse(data);
          if (result.access_token) {
            config.token = result.access_token;
            writeJSON('shopify-config.json', config);
            resolve(true);
          } else { resolve(false); }
        } catch { resolve(false); }
      });
    });
    req.on('error', () => resolve(false));
    req.on('timeout', () => { req.destroy(); resolve(false); });
    req.write(postData);
    req.end();
  });
}

function shopifyRequest(method, endpoint, body) {
  const config = readJSON('shopify-config.json');
  if (!config || !config.token) return Promise.reject(new Error('Not connected to Shopify'));
  const store = config.store;
  const url = `https://${store}/admin/api/2025-01${endpoint}`;

  return new Promise((resolve, reject) => {
    const parsed = new URL(url);
    const options = {
      hostname: parsed.hostname,
      path: parsed.pathname + parsed.search,
      method,
      headers: {
        'Content-Type': 'application/json',
        'X-Shopify-Access-Token': config.token
      },
      timeout: 30000
    };

    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', chunk => { data += chunk; });
      res.on('end', () => {
        try {
          resolve({ status: res.statusCode, data: JSON.parse(data), headers: res.headers });
        } catch {
          resolve({ status: res.statusCode, data, headers: res.headers });
        }
      });
    });

    req.on('error', reject);
    req.on('timeout', () => { req.destroy(); reject(new Error('Request timeout')); });
    if (body) req.write(JSON.stringify(body));
    req.end();
  });
}

function generateOrderRef(counter) {
  const now = new Date();
  const yy = String(now.getFullYear()).slice(2);
  const mm = String(now.getMonth() + 1).padStart(2, '0');
  const dd = String(now.getDate()).padStart(2, '0');
  const seq = String(counter).padStart(5, '0');
  return `${yy}${mm}${dd}${seq}`;
}

function getNextCounter() {
  const shift = readJSON('shift.json');
  if (!shift) return 1;
  const today = new Date().toISOString().slice(0, 10);
  const shiftDay = shift.openedAt ? shift.openedAt.slice(0, 10) : today;
  if (shiftDay !== today) {
    shift.nextOrderCounter = 1;
    writeJSON('shift.json', shift);
  }
  return shift.nextOrderCounter || 1;
}

// ══════════════════════════════════════════════════════
// AUTH
// ══════════════════════════════════════════════════════
const STAFF = [
  { id: 1, name: 'Admin', role: 'admin' },
  { id: 2, name: 'Cashier', role: 'cashier' }
];

app.post('/api/login', (req, res) => {
  const { userId, pin } = req.body;
  const pins = readJSON('pins.json') || { '1': '1234', '2': '6666' };
  const user = STAFF.find(u => u.id === userId);
  if (!user) return res.status(400).json({ error: 'User not found' });
  if (pins[String(userId)] !== pin) return res.status(401).json({ error: 'Wrong PIN' });
  res.json(user);
});

app.get('/api/pins', (req, res) => {
  res.json({ staff: STAFF.map(u => ({ id: u.id, name: u.name, role: u.role })) });
});

app.post('/api/pin-change', (req, res) => {
  const { requesterId, requesterPin, targetId, newPin } = req.body;
  const pins = readJSON('pins.json') || { '1': '1234', '2': '6666' };

  if (String(requesterId) !== '1') return res.status(403).json({ error: 'Only admin can change PINs' });
  if (pins['1'] !== requesterPin) return res.status(401).json({ error: 'Wrong admin PIN' });
  if (!/^\d{4}$/.test(newPin)) return res.status(400).json({ error: 'PIN must be 4 digits' });

  pins[String(targetId)] = newPin;
  writeJSON('pins.json', pins);
  res.json({ ok: true });
});

// ══════════════════════════════════════════════════════
// PRODUCTS
// ══════════════════════════════════════════════════════
const FALLBACK_PRODUCTS = [
  { id: 1, title: 'Baby Onesie', price: 250, category: 'Clothing', emoji: '👶', barcode: '1001', sku: 'BO-001' },
  { id: 2, title: 'Teddy Bear Small', price: 350, category: 'Toys', emoji: '🧸', barcode: '1002', sku: 'TB-S01' },
  { id: 3, title: 'Kids T-Shirt', price: 180, category: 'Clothing', emoji: '👕', barcode: '1003', sku: 'KT-001' },
  { id: 4, title: 'Swim Shorts', price: 220, category: 'Swimwear', emoji: '🩳', barcode: '1004', sku: 'SS-001' },
  { id: 5, title: 'Baby Shoes', price: 320, category: 'Clothing', emoji: '👟', barcode: '1005', sku: 'BS-001' },
  { id: 6, title: 'Stuffed Bunny', price: 280, category: 'Toys', emoji: '🐰', barcode: '1006', sku: 'SB-001' },
  { id: 7, title: 'Kids Dress', price: 450, category: 'Clothing', emoji: '👗', barcode: '1007', sku: 'KD-001' },
  { id: 8, title: 'Beach Ball', price: 90, category: 'Toys', emoji: '🏐', barcode: '1008', sku: 'BB-001' },
  { id: 9, title: 'Baby Hat', price: 120, category: 'Clothing', emoji: '🧢', barcode: '1009', sku: 'BH-001' },
  { id: 10, title: 'Swim Goggles', price: 150, category: 'Swimwear', emoji: '🥽', barcode: '1010', sku: 'SG-001' },
  { id: 11, title: 'Plush Dinosaur', price: 400, category: 'Toys', emoji: '🦕', barcode: '1011', sku: 'PD-001' },
  { id: 12, title: 'Kids Pajamas', price: 290, category: 'Clothing', emoji: '🌙', barcode: '1012', sku: 'KP-001' }
];

app.get('/api/products', (req, res) => {
  const products = readJSON('shopify-products.json');
  if (products && products.length > 0) return res.json(products);
  res.json(FALLBACK_PRODUCTS);
});

app.get('/api/barcode', (req, res) => {
  const code = (req.query.c || '').toLowerCase();
  if (!code) return res.status(400).json({ error: 'No code provided' });

  const products = readJSON('shopify-products.json');
  const list = (products && products.length > 0) ? products : FALLBACK_PRODUCTS;
  const found = list.find(p =>
    (p.barcode || '').toLowerCase() === code || (p.sku || '').toLowerCase() === code
  );
  if (!found) return res.status(404).json({ error: 'Product not found' });
  res.json(found);
});

// ══════════════════════════════════════════════════════
// SHIFT
// ══════════════════════════════════════════════════════
app.post('/api/shift-status', (req, res) => {
  const shift = readJSON('shift.json');
  if (shift) return res.json({ hasOpenShift: true, shift });
  res.json({ hasOpenShift: false });
});

app.post('/api/shift-open', (req, res) => {
  const existing = readJSON('shift.json');
  if (existing) return res.status(400).json({ error: 'A shift is already open' });

  const { openedBy, openingCash } = req.body;
  const shift = {
    id: 'SHF-' + Date.now(),
    openedBy: openedBy || 'Unknown',
    openedAt: new Date().toISOString(),
    openingCash: openingCash || 0,
    orders: [],
    totalCash: 0,
    totalVisa: 0,
    totalTransfer: 0,
    nextOrderCounter: 1
  };
  writeJSON('shift.json', shift);
  res.json({ ok: true, shift });
});

app.post('/api/shift-close', (req, res) => {
  const shift = readJSON('shift.json');
  if (!shift) return res.status(400).json({ error: 'No open shift' });

  shift.closedAt = new Date().toISOString();
  const archiveFile = `shift_${shift.id}.json`;
  writeJSON(archiveFile, shift);

  const shiftPath = path.join(DATA_DIR, 'shift.json');
  if (fs.existsSync(shiftPath)) fs.unlinkSync(shiftPath);

  res.json({ ok: true, shift });
});

// ══════════════════════════════════════════════════════
// ORDERS
// ══════════════════════════════════════════════════════
app.post('/api/order', async (req, res) => {
  const shift = readJSON('shift.json');
  if (!shift) return res.status(400).json({ error: 'No open shift' });

  const { items, payment, discount, subtotal, tax, total, cashGiven, note, customerId, customerName, customerPhone } = req.body;

  const counter = getNextCounter();
  const ref = generateOrderRef(counter);
  shift.nextOrderCounter = counter + 1;

  const order = {
    ref,
    type: 'sale',
    items: items.map(i => ({ id: i.id, variantId: i.variantId, inventoryItemId: i.inventoryItemId, title: i.title, price: i.price, quantity: i.quantity, returnedQty: 0 })),
    payment,
    discount: discount || 0,
    subtotal,
    tax,
    total,
    cashGiven: cashGiven || 0,
    note: note || '',
    date: new Date().toISOString(),
    customerId: customerId || null,
    customerName: customerName || '',
    customerPhone: customerPhone || '',
    cashier: shift.openedBy,
    shopifyOrderId: null
  };

  // Push to Shopify
  const config = readJSON('shopify-config.json');
  if (config && config.token) {
    try {
      const lineItems = items.map(i => ({
        variant_id: i.variantId,
        quantity: i.quantity
      })).filter(li => li.variant_id);

      const gateway = payment === 'cash' ? 'Cash' : payment === 'visa' ? 'Visa' : 'Bank Transfer';
      const shopifyOrder = {
        order: {
          line_items: lineItems.length > 0 ? lineItems : items.map(i => ({ title: i.title, price: i.price, quantity: i.quantity })),
          financial_status: 'paid',
          source_name: 'Teddy POS',
          note: note || '',
          transactions: [{
            kind: 'sale',
            status: 'success',
            amount: total.toFixed(2),
            gateway
          }]
        }
      };

      if (customerId) {
        shopifyOrder.order.customer = { id: customerId };
      }

      const result = await shopifyRequest('POST', '/orders.json', shopifyOrder);
      if (result.status >= 200 && result.status < 300 && result.data.order) {
        order.shopifyOrderId = result.data.order.id;

        // Adjust inventory
        if (config.locationId) {
          for (const item of items) {
            if (item.inventoryItemId) {
              try {
                await shopifyRequest('POST', '/inventory_levels/adjust.json', {
                  location_id: parseInt(config.locationId),
                  inventory_item_id: item.inventoryItemId,
                  available_adjustment: -item.quantity
                });
              } catch {}
            }
          }
        }
      }
    } catch {}
  }

  // Update shift
  shift.orders.push(order);
  if (payment === 'cash') shift.totalCash += total;
  else if (payment === 'visa') shift.totalVisa += total;
  else if (payment === 'transfer') shift.totalTransfer += total;
  writeJSON('shift.json', shift);

  // Save to history
  const history = readJSON('orders-history.json') || [];
  history.unshift(order);
  writeJSON('orders-history.json', history);

  res.json({ ok: true, orderId: ref, shift });
});

app.get('/api/orders-history', (req, res) => {
  const history = readJSON('orders-history.json') || [];
  res.json({ orders: history });
});

app.get('/api/order-lookup', (req, res) => {
  const ref = req.query.ref;
  if (!ref) return res.status(400).json({ error: 'No ref provided' });
  const history = readJSON('orders-history.json') || [];
  const order = history.find(o => o.ref === ref);
  if (!order) return res.status(404).json({ error: 'Order not found' });
  res.json({ order });
});

// ══════════════════════════════════════════════════════
// RETURNS
// ══════════════════════════════════════════════════════
app.post('/api/order-return', async (req, res) => {
  const { ref, returnItems, reason } = req.body;
  const history = readJSON('orders-history.json') || [];
  const original = history.find(o => o.ref === ref && o.type === 'sale');
  if (!original) return res.status(404).json({ error: 'Original sale not found' });

  // Validate quantities
  const returnedItems = [];
  for (const ri of returnItems) {
    const origItem = original.items.find(i => String(i.id) === String(ri.id));
    if (!origItem) continue;
    const maxReturn = origItem.quantity - (origItem.returnedQty || 0);
    const qty = Math.min(ri.quantity, maxReturn);
    if (qty <= 0) continue;
    returnedItems.push({ ...origItem, quantity: qty });
  }

  if (!returnedItems.length) return res.status(400).json({ error: 'No valid items to return' });

  // Calculate return amounts
  const returnSubtotal = returnedItems.reduce((s, i) => s + i.price * i.quantity, 0);
  const originalSubtotal = original.subtotal || original.items.reduce((s, i) => s + i.price * i.quantity, 0);
  const discountRatio = originalSubtotal > 0 ? (original.discount || 0) / originalSubtotal : 0;
  const returnDiscount = returnSubtotal * discountRatio;
  const taxable = returnSubtotal - returnDiscount;
  const returnTax = taxable * 0.14;
  const returnTotal = taxable + returnTax;

  // Generate return ref (does NOT consume sequence — use current counter without incrementing)
  const shift = readJSON('shift.json');
  const returnRef = generateOrderRef(shift ? (shift.nextOrderCounter || 1) : 1);

  const returnOrder = {
    ref: returnRef,
    type: 'return',
    originalRef: ref,
    items: returnedItems,
    payment: original.payment,
    reason: reason || '',
    discount: returnDiscount,
    subtotal: returnSubtotal,
    tax: returnTax,
    total: returnTotal,
    date: new Date().toISOString(),
    cashier: shift ? shift.openedBy : 'Unknown',
    shopifyOrderId: original.shopifyOrderId
  };

  // Update returnedQty on original
  for (const ri of returnedItems) {
    const origItem = original.items.find(i => String(i.id) === String(ri.id));
    if (origItem) origItem.returnedQty = (origItem.returnedQty || 0) + ri.quantity;
  }

  // Save return to history
  history.unshift(returnOrder);
  writeJSON('orders-history.json', history);

  // Adjust shift totals
  if (shift) {
    if (original.payment === 'cash') shift.totalCash -= returnTotal;
    else if (original.payment === 'visa') shift.totalVisa -= returnTotal;
    else if (original.payment === 'transfer') shift.totalTransfer -= returnTotal;
    shift.orders.push(returnOrder);
    writeJSON('shift.json', shift);
  }

  // Shopify: refund + cancel + restore inventory
  const config = readJSON('shopify-config.json');
  if (config && config.token && original.shopifyOrderId) {
    try {
      // Refund
      await shopifyRequest('POST', `/orders/${original.shopifyOrderId}/refunds.json`, {
        refund: {
          notify: false,
          transactions: [{
            kind: 'refund',
            amount: returnTotal.toFixed(2),
            gateway: original.payment === 'cash' ? 'Cash' : original.payment === 'visa' ? 'Visa' : 'Bank Transfer'
          }],
          restock_type: 'no_restock'
        }
      });

      // Cancel
      await shopifyRequest('POST', `/orders/${original.shopifyOrderId}/cancel.json`, {
        reason: 'customer'
      });

      // Restore inventory
      if (config.locationId) {
        for (const item of returnedItems) {
          if (item.inventoryItemId) {
            try {
              await shopifyRequest('POST', '/inventory_levels/adjust.json', {
                location_id: parseInt(config.locationId),
                inventory_item_id: item.inventoryItemId,
                available_adjustment: item.quantity
              });
            } catch {}
          }
        }
      }
    } catch {}
  }

  res.json({ ok: true, returnRef, returnTotal });
});

// ══════════════════════════════════════════════════════
// SHOPIFY
// ══════════════════════════════════════════════════════
app.post('/api/shopify-connect', (req, res) => {
  const { store, clientId, clientSecret } = req.body;
  if (!store || !clientId || !clientSecret) return res.status(400).json({ error: 'Missing fields' });

  const postData = JSON.stringify({
    client_id: clientId,
    client_secret: clientSecret,
    grant_type: 'client_credentials'
  });

  const parsed = new URL(`https://${store}/admin/oauth/access_token`);
  const options = {
    hostname: parsed.hostname,
    path: parsed.pathname,
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Content-Length': Buffer.byteLength(postData)
    }
  };

  const request = https.request(options, (response) => {
    let data = '';
    response.on('data', chunk => { data += chunk; });
    response.on('end', () => {
      try {
        const result = JSON.parse(data);
        if (result.access_token) {
          const config = { store, clientId, clientSecret, token: result.access_token, locationId: null };
          writeJSON('shopify-config.json', config);

          // Fetch location
          shopifyRequest('GET', '/locations.json').then(loc => {
            if (loc.data && loc.data.locations && loc.data.locations.length > 0) {
              config.locationId = String(loc.data.locations[0].id);
              writeJSON('shopify-config.json', config);
            }
          }).catch(() => {});

          res.json({ ok: true, store });
        } else {
          res.status(400).json({ error: result.error_description || result.error || 'Auth failed' });
        }
      } catch {
        res.status(500).json({ error: 'Invalid response from Shopify' });
      }
    });
  });

  request.on('error', (e) => res.status(500).json({ error: e.message }));
  request.write(postData);
  request.end();
});

app.get('/api/shopify-config', (req, res) => {
  const config = readJSON('shopify-config.json');
  if (!config || !config.token) return res.json({ connected: false });
  const products = readJSON('shopify-products.json') || [];
  res.json({
    connected: true,
    store: config.store,
    productsCount: products.length
  });
});

app.post('/api/shopify-config', (req, res) => {
  const config = readJSON('shopify-config.json');
  if (!config) return res.status(400).json({ error: 'Not connected' });
  if (req.body.locationId) config.locationId = req.body.locationId;
  writeJSON('shopify-config.json', config);
  res.json({ ok: true });
});

app.get('/api/locations', async (req, res) => {
  const config = readJSON('shopify-config.json');
  if (!config || !config.token) return res.json({ locations: [] });
  try {
    const result = await shopifyRequest('GET', '/locations.json');
    const locations = (result.data && result.data.locations) || [];
    const mapped = locations.map(l => ({ id: String(l.id), name: l.name }));
    res.json({ locations: mapped });
  } catch { res.json({ locations: [] }); }
});

app.post('/api/shopify-sync', async (req, res) => {
  let config = readJSON('shopify-config.json');
  if (!config || !config.token) return res.status(400).json({ error: 'Not connected to Shopify' });

  // Refresh token before sync (client_credentials tokens expire after 24h)
  await refreshShopifyToken();
  config = readJSON('shopify-config.json');

  try {
    let allProducts = [];
    let sinceId = 0;
    let hasMore = true;

    while (hasMore) {
      const endpoint = `/products.json?limit=250&status=active${sinceId ? '&since_id=' + sinceId : ''}`;
      const result = await shopifyRequest('GET', endpoint);

      if (result.status === 401) {
        // Token expired mid-sync, try refresh once
        const refreshed = await refreshShopifyToken();
        if (!refreshed) return res.status(401).json({ error: 'Shopify auth failed — reconnect required' });
        continue;
      }

      if (result.status >= 400) {
        return res.status(500).json({ error: 'Shopify API error: ' + result.status });
      }

      const products = result.data.products || [];
      for (const p of products) {
        for (const v of (p.variants || [])) {
          allProducts.push({
            id: v.id,
            productId: p.id,
            variantId: v.id,
            inventoryItemId: v.inventory_item_id,
            title: v.title === 'Default Title' ? p.title : `${p.title} - ${v.title}`,
            price: parseFloat(v.price) || 0,
            barcode: v.barcode || '',
            sku: v.sku || '',
            image: (p.image && p.image.src) || '',
            category: p.product_type || 'General'
          });
        }
      }

      if (products.length < 250) {
        hasMore = false;
      } else {
        sinceId = products[products.length - 1].id;
      }
    }

    // Fetch all locations
    let locations = [];
    try {
      const locResult = await shopifyRequest('GET', '/locations.json');
      if (locResult.data && locResult.data.locations) {
        locations = locResult.data.locations.map(l => ({ id: String(l.id), name: l.name }));
      }
    } catch {}

    if (!config.locationId && locations.length > 0) {
      config.locationId = locations[0].id;
      writeJSON('shopify-config.json', config);
    }

    // Fetch inventory levels per location for all products
    const locationIds = locations.map(l => l.id);
    if (locationIds.length > 0) {
      const inventoryItemIds = allProducts.map(p => p.inventoryItemId).filter(Boolean);
      const batchSize = 50;
      for (let i = 0; i < inventoryItemIds.length; i += batchSize) {
        const batch = inventoryItemIds.slice(i, i + batchSize);
        try {
          const invResult = await shopifyRequest('GET',
            `/inventory_levels.json?inventory_item_ids=${batch.join(',')}&location_ids=${locationIds.join(',')}&limit=250`
          );
          const levels = (invResult.data && invResult.data.inventory_levels) || [];
          for (const level of levels) {
            const product = allProducts.find(p => p.inventoryItemId === level.inventory_item_id);
            if (product) {
              if (!product.locationStock) product.locationStock = {};
              product.locationStock[String(level.location_id)] = level.available || 0;
            }
          }
        } catch {}
      }
    }

    // Save locations list
    writeJSON('locations.json', locations);
    writeJSON('shopify-products.json', allProducts);
    res.json({ ok: true, count: allProducts.length });
  } catch (e) {
    res.status(500).json({ error: 'Sync failed: ' + e.message });
  }
});

app.post('/api/shopify-disconnect', (req, res) => {
  writeJSON('shopify-config.json', {});
  writeJSON('shopify-products.json', []);
  res.json({ ok: true });
});

// ══════════════════════════════════════════════════════
// CUSTOMERS
// ══════════════════════════════════════════════════════
app.get('/api/customer', async (req, res) => {
  const phone = req.query.phone;
  if (!phone) return res.status(400).json({ error: 'Phone required' });

  const config = readJSON('shopify-config.json');
  if (!config || !config.token) return res.status(404).json({ error: 'Customer not found' });

  try {
    const result = await shopifyRequest('GET', `/customers/search.json?query=phone:${encodeURIComponent(phone)}`);
    const customers = result.data.customers || [];
    if (customers.length === 0) return res.status(404).json({ error: 'Customer not found' });
    const c = customers[0];
    res.json({
      customer: {
        id: c.id,
        firstName: c.first_name || '',
        lastName: c.last_name || '',
        phone: c.phone || phone,
        email: c.email || ''
      }
    });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.post('/api/customer', async (req, res) => {
  const { firstName, lastName, phone, email } = req.body;
  if (!firstName || !phone) return res.status(400).json({ error: 'Name and phone required' });

  const config = readJSON('shopify-config.json');
  if (!config || !config.token) return res.status(500).json({ error: 'Shopify not connected' });

  try {
    const result = await shopifyRequest('POST', '/customers.json', {
      customer: {
        first_name: firstName,
        last_name: lastName || '',
        phone,
        email: email || null
      }
    });
    if (result.status >= 400) {
      const errors = result.data.errors;
      const msg = typeof errors === 'object' ? JSON.stringify(errors) : (errors || 'Failed to create customer');
      return res.status(400).json({ error: msg });
    }
    const c = result.data.customer;
    res.json({
      customer: {
        id: c.id,
        firstName: c.first_name || '',
        lastName: c.last_name || '',
        phone: c.phone || phone,
        email: c.email || ''
      }
    });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ══════════════════════════════════════════════════════
// PRINTER
// ══════════════════════════════════════════════════════
let activePrinter = 'XP-80C';
let cachedPrinters = [];

function discoverPrinters() {
  if (process.platform !== 'win32') {
    return [{ name: 'XP-80C', driver: 'Generic', port: 'USB', status: 'Ready', active: true }];
  }

  try {
    const vbsContent = `
Set objWMI = GetObject("winmgmts:\\\\.\\root\\cimv2")
Set printers = objWMI.ExecQuery("SELECT Name, DriverName, PortName, PrinterStatus FROM Win32_Printer")
For Each p In printers
  Dim stat
  Select Case p.PrinterStatus
    Case 3, 4: stat = "Ready"
    Case 7: stat = "Offline"
    Case Else: stat = "Unknown"
  End Select
  WScript.Echo p.Name & "|" & p.DriverName & "|" & p.PortName & "|" & stat
Next`;

    const vbsPath = path.join(DATA_DIR, '_printers.vbs');
    fs.writeFileSync(vbsPath, vbsContent);
    const output = execSync(`cscript //nologo "${vbsPath}"`, { encoding: 'utf8', timeout: 10000 });
    try { fs.unlinkSync(vbsPath); } catch {}

    const printers = output.trim().split('\n').filter(Boolean).map(line => {
      const [name, driver, port, status] = line.trim().split('|');
      return { name: name || '', driver: driver || '', port: port || '', status: status || 'Unknown', active: false };
    });

    printers.forEach(p => { p.active = (p.name === activePrinter); });
    return printers;
  } catch {
    return [{ name: activePrinter, driver: 'Unknown', port: 'Unknown', status: 'Unknown', active: true }];
  }
}

app.get('/api/printer', (req, res) => {
  res.json({ active: activePrinter, printers: cachedPrinters });
});

app.post('/api/printer-select', (req, res) => {
  const { name } = req.body;
  if (!name) return res.status(400).json({ error: 'Printer name required' });
  activePrinter = name;
  cachedPrinters.forEach(p => { p.active = (p.name === name); });
  res.json({ ok: true, active: activePrinter });
});

app.post('/api/printer-refresh', (req, res) => {
  cachedPrinters = discoverPrinters();
  res.json({ active: activePrinter, printers: cachedPrinters });
});

// ══════════════════════════════════════════════════════
// START
// ══════════════════════════════════════════════════════
app.listen(PORT, () => {
  console.log(`Teddy POS running at http://localhost:${PORT}`);
  cachedPrinters = discoverPrinters();
});
