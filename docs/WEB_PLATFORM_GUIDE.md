# 🌐 Web Platform Documentation

## 🚀 **Complete Web Implementation Guide**

---

## 📋 **Overview**

This comprehensive guide covers the complete Web platform implementation for the **Katya AI REChain Mesh** Flutter application. The Web platform supports modern web browsers with advanced PWA capabilities, offline support, and comprehensive web ecosystem integration.

---

## 🏗️ **Project Structure**

```
web/
├── index.html                        # Main HTML file
├── manifest.json                     # Web App Manifest (PWA)
├── service-worker.js                 # Service Worker for offline support
├── flutter_service_worker.js         # Flutter-generated service worker
├── assets/                          # Web assets
│   ├── icons/                       # Web app icons
│   ├── images/                      # Web images
│   └── fonts/                        # Web fonts
├── scripts/                         # Web-specific scripts
├── styles/                          # Web-specific styles
├── build/                           # Web build output
└── .well-known/                     # Well-known URLs
    └── assetlinks.json              # App Links for Android
```

---

## ⚙️ **Configuration Files**

### **index.html**

Main HTML file with comprehensive meta tags and PWA configuration:

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Katya AI REChain Mesh - Advanced Blockchain AI Application">
    <meta name="keywords" content="blockchain, AI, REChain, mesh, network, cryptocurrency, decentralized, PWA">
    <meta name="author" content="Katya AI REChain Mesh Team">
    <meta name="robots" content="index, follow">
    <meta name="theme-color" content="#1a1a1a">
    <meta name="msapplication-TileColor" content="#1a1a1a">

    <!-- Open Graph meta tags -->
    <meta property="og:title" content="Katya AI REChain Mesh">
    <meta property="og:description" content="Advanced Blockchain AI Application">
    <meta property="og:type" content="website">
    <meta property="og:url" content="https://katyaairechainmesh.com">
    <meta property="og:image" content="https://katyaairechainmesh.com/assets/icons/icon-512x512.png">
    <meta property="og:site_name" content="Katya AI REChain Mesh">

    <!-- Twitter Card meta tags -->
    <meta name="twitter:card" content="summary_large_image">
    <meta name="twitter:title" content="Katya AI REChain Mesh">
    <meta name="twitter:description" content="Advanced Blockchain AI Application">
    <meta name="twitter:image" content="https://katyaairechainmesh.com/assets/icons/icon-512x512.png">

    <!-- PWA meta tags -->
    <meta name="application-name" content="Katya AI REChain Mesh">
    <meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
    <meta name="apple-mobile-web-app-title" content="Katya AI REChain Mesh">
    <meta name="mobile-web-app-capable" content="yes">
    <meta name="msapplication-tap-highlight" content="no">

    <!-- Security headers -->
    <meta http-equiv="Content-Security-Policy" content="default-src 'self'; script-src 'self' 'unsafe-eval' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self' data:; connect-src 'self' https: wss:; media-src 'self' data:; object-src 'none'; base-uri 'self'; form-action 'self'; frame-ancestors 'none';">
    <meta http-equiv="X-Content-Type-Options" content="nosniff">
    <meta http-equiv="X-Frame-Options" content="DENY">
    <meta http-equiv="X-XSS-Protection" content="1; mode=block">
    <meta http-equiv="Referrer-Policy" content="strict-origin-when-cross-origin">

    <!-- DNS prefetching -->
    <link rel="dns-prefetch" href="//fonts.googleapis.com">
    <link rel="dns-prefetch" href="//www.google-analytics.com">
    <link rel="dns-prefetch" href="//api.katyaairechainmesh.com">

    <!-- Preconnect -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://api.katyaairechainmesh.com">

    <!-- Favicon -->
    <link rel="icon" type="image/x-icon" href="/favicon.ico">
    <link rel="icon" type="image/png" sizes="16x16" href="/assets/icons/favicon-16x16.png">
    <link rel="icon" type="image/png" sizes="32x32" href="/assets/icons/favicon-32x32.png">
    <link rel="apple-touch-icon" sizes="180x180" href="/assets/icons/apple-touch-icon.png">
    <link rel="mask-icon" href="/assets/icons/safari-pinned-tab.svg" color="#1a1a1a">

    <!-- Web App Manifest -->
    <link rel="manifest" href="/manifest.json">

    <!-- Theme color -->
    <meta name="theme-color" content="#1a1a1a">
    <meta name="msapplication-TileColor" content="#1a1a1a">
    <meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">

    <title>Katya AI REChain Mesh</title>

    <!-- Preload critical resources -->
    <link rel="preload" href="/main.dart.js" as="script">
    <link rel="preload" href="/assets/fonts/Inter-Regular.woff2" as="font" type="font/woff2" crossorigin>

    <!-- Stylesheets -->
    <link rel="stylesheet" href="/styles/main.css">

    <!-- Flutter web -->
    <script src="https://www.gstatic.com/firebasejs/9.0.0/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.0.0/firebase-analytics-compat.js"></script>

    <script>
        // Initialize Firebase
        if (typeof firebase !== 'undefined') {
            firebase.initializeApp({
                apiKey: "your-api-key",
                authDomain: "katyaairechainmesh.firebaseapp.com",
                projectId: "katya-ai-rechain-mesh",
                storageBucket: "katya-ai-rechain-mesh.appspot.com",
                messagingSenderId: "123456789",
                appId: "1:123456789:web:abcdef123456",
                measurementId: "G-XXXXXXXXXX"
            });

            // Initialize Analytics
            firebase.analytics();
        }

        // Web Vitals monitoring
        if (typeof gtag !== 'undefined') {
            gtag('config', 'G-XXXXXXXXXX');
        }

        // Service Worker registration
        if ('serviceWorker' in navigator) {
            window.addEventListener('load', function() {
                navigator.serviceWorker.register('/flutter_service_worker.js')
                    .then(function(registration) {
                        console.log('SW registered: ', registration);
                    })
                    .catch(function(registrationError) {
                        console.log('SW registration failed: ', registrationError);
                    });
            });
        }

        // Performance monitoring
        if (typeof PerformanceObserver !== 'undefined') {
            const observer = new PerformanceObserver((list) => {
                for (const entry of list.getEntries()) {
                    console.log('Performance entry:', entry.name, entry.startTime, entry.duration);
                }
            });

            observer.observe({ entryTypes: ['measure', 'navigation', 'paint'] });
        }
    </script>
</head>
<body>
    <!-- Loading screen -->
    <div id="loading" class="loading-screen">
        <div class="loading-content">
            <div class="loading-spinner"></div>
            <div class="loading-text">Loading Katya AI REChain Mesh...</div>
            <div class="loading-progress">
                <div class="loading-bar"></div>
            </div>
        </div>
    </div>

    <!-- Main Flutter app -->
    <div id="flutter_app">
        <!-- Flutter will inject its content here -->
    </div>

    <!-- Error fallback -->
    <noscript>
        <div class="noscript-error">
            <h1>JavaScript Required</h1>
            <p>This application requires JavaScript to run. Please enable JavaScript in your browser settings and reload the page.</p>
        </div>
    </noscript>

    <!-- Flutter bootstrap script -->
    <script src="/main.dart.js"></script>

    <!-- Additional scripts -->
    <script src="/scripts/web_analytics.js"></script>
    <script src="/scripts/web_performance.js"></script>
    <script src="/scripts/web_security.js"></script>
</body>
</html>
```

### **manifest.json**

Progressive Web App manifest:

```json
{
    "name": "Katya AI REChain Mesh",
    "short_name": "Katya AI",
    "description": "Advanced Blockchain AI Application for Web",
    "start_url": "/",
    "display": "standalone",
    "background_color": "#1a1a1a",
    "theme_color": "#1a1a1a",
    "orientation": "portrait-primary",
    "scope": "/",
    "lang": "en",
    "dir": "ltr",
    "categories": ["finance", "productivity", "utilities"],
    "shortcuts": [
        {
            "name": "New Transaction",
            "short_name": "New Tx",
            "description": "Create a new blockchain transaction",
            "url": "/?action=new-transaction",
            "icons": [
                {
                    "src": "/assets/icons/shortcut-transaction.png",
                    "sizes": "96x96",
                    "type": "image/png"
                }
            ]
        },
        {
            "name": "View Wallet",
            "short_name": "Wallet",
            "description": "View blockchain wallet",
            "url": "/?action=view-wallet",
            "icons": [
                {
                    "src": "/assets/icons/shortcut-wallet.png",
                    "sizes": "96x96",
                    "type": "image/png"
                }
            ]
        }
    ],
    "icons": [
        {
            "src": "/assets/icons/icon-72x72.png",
            "sizes": "72x72",
            "type": "image/png",
            "purpose": "maskable any"
        },
        {
            "src": "/assets/icons/icon-96x96.png",
            "sizes": "96x96",
            "type": "image/png",
            "purpose": "maskable any"
        },
        {
            "src": "/assets/icons/icon-128x128.png",
            "sizes": "128x128",
            "type": "image/png",
            "purpose": "maskable any"
        },
        {
            "src": "/assets/icons/icon-144x144.png",
            "sizes": "144x144",
            "type": "image/png",
            "purpose": "maskable any"
        },
        {
            "src": "/assets/icons/icon-152x152.png",
            "sizes": "152x152",
            "type": "image/png",
            "purpose": "maskable any"
        },
        {
            "src": "/assets/icons/icon-192x192.png",
            "sizes": "192x192",
            "type": "image/png",
            "purpose": "maskable any"
        },
        {
            "src": "/assets/icons/icon-384x384.png",
            "sizes": "384x384",
            "type": "image/png",
            "purpose": "maskable any"
        },
        {
            "src": "/assets/icons/icon-512x512.png",
            "sizes": "512x512",
            "type": "image/png",
            "purpose": "maskable any"
        }
    ],
    "screenshots": [
        {
            "src": "/assets/screenshots/desktop-wide.png",
            "sizes": "1280x720",
            "type": "image/png",
            "form_factor": "wide"
        },
        {
            "src": "/assets/screenshots/desktop-narrow.png",
            "sizes": "750x1334",
            "type": "image/png",
            "form_factor": "narrow"
        },
        {
            "src": "/assets/screenshots/mobile.png",
            "sizes": "390x844",
            "type": "image/png",
            "form_factor": "narrow"
        }
    ],
    "prefer_related_applications": false,
    "related_applications": [],
    "iarc_rating_id": "e84b072d-71b3-4d3e-86ae-31a8ce4e53b7",
    "edge_side_panel": {
        "preferred_width": 400
    },
    "launch_handler": {
        "client_mode": "navigate-existing"
    },
    "file_handlers": [
        {
            "action": "/open-file",
            "accept": {
                "application/json": [".json"],
                "application/wallet": [".wallet"],
                "application/key": [".key"]
            }
        }
    ],
    "protocol_handlers": [
        {
            "protocol": "web+katya",
            "url": "/handle-protocol?type=%s"
        },
        {
            "protocol": "blockchain",
            "url": "/handle-blockchain?data=%s"
        }
    ],
    "share_target": {
        "action": "/share-target",
        "method": "POST",
        "enctype": "multipart/form-data",
        "params": {
            "title": "title",
            "text": "text",
            "url": "url",
            "files": [
                {
                    "name": "files",
                    "accept": ["image/*", "application/json", ".wallet", ".key"]
                }
            ]
        }
    },
    "note_taking": {
        "new_note_url": "/new-note"
    },
    "display_override": ["window-controls-overlay", "standalone", "minimal-ui"]
}
```

### **service-worker.js**

Custom service worker for enhanced offline capabilities:

```javascript
const CACHE_NAME = 'katya-ai-rechain-mesh-v1.0.0';
const STATIC_CACHE_NAME = 'katya-static-v1.0.0';
const DYNAMIC_CACHE_NAME = 'katya-dynamic-v1.0.0';

// Files to cache immediately
const STATIC_ASSETS = [
    '/',
    '/index.html',
    '/manifest.json',
    '/styles/main.css',
    '/scripts/web_analytics.js',
    '/scripts/web_security.js',
    '/assets/icons/icon-192x192.png',
    '/assets/icons/icon-512x512.png',
    '/assets/fonts/Inter-Regular.woff2',
    '/offline.html'
];

// Install event - cache static assets
self.addEventListener('install', (event) => {
    console.log('Service Worker: Installing...');

    event.waitUntil(
        caches.open(STATIC_CACHE_NAME)
            .then((cache) => {
                console.log('Service Worker: Caching static assets');
                return cache.addAll(STATIC_ASSETS);
            })
            .then(() => {
                console.log('Service Worker: Static assets cached');
                return self.skipWaiting();
            })
            .catch((error) => {
                console.error('Service Worker: Failed to cache static assets', error);
            })
    );
});

// Activate event - clean up old caches
self.addEventListener('activate', (event) => {
    console.log('Service Worker: Activating...');

    event.waitUntil(
        caches.keys()
            .then((cacheNames) => {
                return Promise.all(
                    cacheNames
                        .filter((cacheName) => {
                            return cacheName !== STATIC_CACHE_NAME &&
                                   cacheName !== DYNAMIC_CACHE_NAME;
                        })
                        .map((cacheName) => {
                            console.log('Service Worker: Deleting old cache', cacheName);
                            return caches.delete(cacheName);
                        })
                );
            })
            .then(() => {
                console.log('Service Worker: Activated');
                return self.clients.claim();
            })
    );
});

// Fetch event - serve cached content when offline
self.addEventListener('fetch', (event) => {
    const request = event.request;
    const url = new URL(request.url);

    // Skip non-HTTP requests
    if (!request.url.startsWith('http')) {
        return;
    }

    // Handle navigation requests
    if (request.mode === 'navigate') {
        event.respondWith(
            caches.match('/')
                .then((cachedResponse) => {
                    if (cachedResponse) {
                        return cachedResponse;
                    }

                    return fetch(request)
                        .catch(() => {
                            return caches.match('/offline.html');
                        });
                })
        );
        return;
    }

    // Handle API requests
    if (url.pathname.startsWith('/api/')) {
        event.respondWith(
            caches.open(DYNAMIC_CACHE_NAME)
                .then((cache) => {
                    return fetch(request)
                        .then((response) => {
                            // Cache successful API responses
                            if (response.ok) {
                                cache.put(request, response.clone());
                            }
                            return response;
                        })
                        .catch(() => {
                            // Return cached API response if available
                            return caches.match(request);
                        });
                })
        );
        return;
    }

    // Handle static assets
    event.respondWith(
        caches.match(request)
            .then((cachedResponse) => {
                if (cachedResponse) {
                    return cachedResponse;
                }

                return fetch(request)
                    .then((response) => {
                        // Cache successful responses
                        if (response.ok && isCacheableRequest(request)) {
                            const responseClone = response.clone();
                            caches.open(DYNAMIC_CACHE_NAME)
                                .then((cache) => {
                                    cache.put(request, responseClone);
                                });
                        }
                        return response;
                    })
                    .catch(() => {
                        // Return offline fallback for images
                        if (request.destination === 'image') {
                            return caches.match('/assets/icons/icon-192x192.png');
                        }
                    });
            })
    );
});

// Background sync
self.addEventListener('sync', (event) => {
    console.log('Service Worker: Background sync triggered', event.tag);

    if (event.tag === 'background-sync') {
        event.waitUntil(
            // Perform background sync operations
            performBackgroundSync()
        );
    }
});

// Push notifications
self.addEventListener('push', (event) => {
    console.log('Service Worker: Push notification received');

    const options = {
        body: event.data ? event.data.text() : 'New notification',
        icon: '/assets/icons/icon-192x192.png',
        badge: '/assets/icons/badge-72x72.png',
        vibrate: [100, 50, 100],
        data: {
            dateOfArrival: Date.now(),
            primaryKey: '1'
        },
        actions: [
            {
                action: 'explore',
                title: 'Explore',
                icon: '/assets/icons/explore.png'
            },
            {
                action: 'close',
                title: 'Close',
                icon: '/assets/icons/close.png'
            }
        ]
    };

    event.waitUntil(
        self.registration.showNotification('Katya AI REChain Mesh', options)
    );
});

// Notification click handling
self.addEventListener('notificationclick', (event) => {
    console.log('Service Worker: Notification clicked');

    event.notification.close();

    if (event.action === 'explore') {
        // Handle explore action
        event.waitUntil(
            clients.openWindow('/')
        );
    } else if (event.action === 'close') {
        // Handle close action (already closed above)
        return;
    } else {
        // Handle default click
        event.waitUntil(
            clients.matchAll().then((clientList) => {
                for (let client of clientList) {
                    if (client.url === '/' && 'focus' in client) {
                        return client.focus();
                    }
                }
                if (clients.openWindow) {
                    return clients.openWindow('/');
                }
            })
        );
    }
});

// Message handling from main thread
self.addEventListener('message', (event) => {
    console.log('Service Worker: Message received', event.data);

    if (event.data && event.data.type === 'SKIP_WAITING') {
        self.skipWaiting();
    }

    if (event.data && event.data.type === 'GET_CACHE_INFO') {
        event.ports[0].postMessage({
            staticCache: STATIC_CACHE_NAME,
            dynamicCache: DYNAMIC_CACHE_NAME,
            cacheCount: caches.keys().length
        });
    }
});

// Helper functions
function isCacheableRequest(request) {
    // Determine if a request should be cached
    const url = new URL(request.url);

    // Cache GET requests
    if (request.method !== 'GET') {
        return false;
    }

    // Don't cache API requests (handled separately)
    if (url.pathname.startsWith('/api/')) {
        return false;
    }

    // Cache static assets
    if (url.pathname.match(/\.(css|js|png|jpg|jpeg|gif|svg|webp|woff|woff2|ttf|eot)$/i)) {
        return true;
    }

    // Cache HTML pages
    if (url.pathname.match(/\.(html|htm)$/i) || url.pathname === '/') {
        return true;
    }

    return false;
}

async function performBackgroundSync() {
    console.log('Service Worker: Performing background sync');

    try {
        // Sync offline actions
        await syncOfflineActions();

        // Sync user data
        await syncUserData();

        // Update cache
        await updateCache();

        console.log('Service Worker: Background sync completed');
    } catch (error) {
        console.error('Service Worker: Background sync failed', error);
    }
}

async function syncOfflineActions() {
    // Sync offline actions with server
    const offlineActions = await getStoredOfflineActions();

    for (const action of offlineActions) {
        try {
            await sendActionToServer(action);
            await removeOfflineAction(action.id);
        } catch (error) {
            console.error('Failed to sync offline action', action.id, error);
        }
    }
}

async function syncUserData() {
    // Sync user data with server
    const userData = await getStoredUserData();

    try {
        await sendUserDataToServer(userData);
        await clearUserDataSyncFlag();
    } catch (error) {
        console.error('Failed to sync user data', error);
    }
}

async function updateCache() {
    // Update static cache with new versions
    try {
        const response = await fetch('/manifest.json');
        const manifest = await response.json();

        // Update cache based on manifest version
        if (manifest.version !== CACHE_NAME) {
            await updateStaticCache(manifest);
        }
    } catch (error) {
        console.error('Failed to update cache', error);
    }
}

// Storage helper functions
async function getStoredOfflineActions() {
    return new Promise((resolve) => {
        // Implementation to get offline actions from IndexedDB
        resolve([]);
    });
}

async function sendActionToServer(action) {
    // Implementation to send action to server
}

async function removeOfflineAction(actionId) {
    // Implementation to remove offline action
}

async function getStoredUserData() {
    // Implementation to get user data
    return {};
}

async function sendUserDataToServer(userData) {
    // Implementation to send user data to server
}

async function clearUserDataSyncFlag() {
    // Implementation to clear sync flag
}

async function updateStaticCache(manifest) {
    // Implementation to update static cache
}
```

---

## 🔧 **Web Platform Services**

### **JavaScript Integration**

Modern web platform integration with comprehensive browser support:

```javascript
// Web Platform Service
class WebPlatformService {
    constructor() {
        this.initializeWebFeatures();
    }

    initializeWebFeatures() {
        // Initialize Web APIs
        this.setupWebAPIs();
        this.setupPWAFeatures();
        this.setupSecurityFeatures();
        this.setupPerformanceFeatures();
        this.setupAccessibilityFeatures();
    }

    setupWebAPIs() {
        // Web APIs setup
        this.setupGeolocation();
        this.setupCamera();
        this.setupMicrophone();
        this.setupNotifications();
        this.setupClipboard();
        this.setupFileSystem();
        this.setupBluetooth();
        this.setupUSB();
        this.setupWebRTC();
        this.setupWebSockets();
        this.setupServiceWorkers();
        this.setupWebAssembly();
        this.setupWebGL();
        this.setupWebXR();
    }

    setupPWAFeatures() {
        // PWA features setup
        this.registerServiceWorker();
        this.setupInstallPrompt();
        this.setupOfflineSupport();
        this.setupBackgroundSync();
        this.setupPushNotifications();
        this.setupPeriodicBackgroundSync();
        this.setupWebAppManifest();
        this.setupShareTarget();
        this.setupFileHandling();
        this.setupProtocolHandling();
    }

    setupSecurityFeatures() {
        // Security features setup
        this.setupCSP();
        this.setupHSTS();
        this.setupExpectCT();
        this.setupCOOP();
        this.setupCOEP();
        this.setupSecFetch();
        this.setupPermissionsPolicy();
        this.setupCertificateTransparency();
    }

    setupPerformanceFeatures() {
        // Performance features setup
        this.setupWebVitals();
        this.setupPerformanceObserver();
        this.setupResourceTiming();
        this.setupNavigationTiming();
        this.setupPaintTiming();
        this.setupLargestContentfulPaint();
        this.setupFirstInputDelay();
        this.setupCumulativeLayoutShift();
    }

    setupAccessibilityFeatures() {
        // Accessibility features setup
        this.setupScreenReaderSupport();
        this.setupKeyboardNavigation();
        this.setupHighContrastMode();
        this.setupReducedMotion();
        this.setupColorScheme();
        this.setupFocusManagement();
    }

    // Web API methods
    async getCurrentLocation() {
        if (!navigator.geolocation) {
            throw new Error('Geolocation not supported');
        }

        return new Promise((resolve, reject) => {
            navigator.geolocation.getCurrentPosition(
                (position) => resolve(position),
                (error) => reject(error),
                {
                    enableHighAccuracy: true,
                    timeout: 10000,
                    maximumAge: 60000
                }
            );
        });
    }

    async requestCameraPermission() {
        try {
            const stream = await navigator.mediaDevices.getUserMedia({
                video: {
                    width: { ideal: 1920 },
                    height: { ideal: 1080 },
                    facingMode: 'user'
                }
            });
            return stream;
        } catch (error) {
            throw new Error(`Camera permission denied: ${error.message}`);
        }
    }

    async requestMicrophonePermission() {
        try {
            const stream = await navigator.mediaDevices.getUserMedia({
                audio: {
                    echoCancellation: true,
                    noiseSuppression: true,
                    sampleRate: 44100
                }
            });
            return stream;
        } catch (error) {
            throw new Error(`Microphone permission denied: ${error.message}`);
        }
    }

    async showNotification(title, options = {}) {
        if (!('Notification' in window)) {
            throw new Error('Notifications not supported');
        }

        if (Notification.permission === 'granted') {
            return new Notification(title, {
                body: options.body || '',
                icon: options.icon || '/assets/icons/icon-192x192.png',
                badge: options.badge || '/assets/icons/badge-72x72.png',
                tag: options.tag || '',
                requireInteraction: options.requireInteraction || false,
                actions: options.actions || [],
                data: options.data || {},
                ...options
            });
        } else if (Notification.permission !== 'denied') {
            const permission = await Notification.requestPermission();
            if (permission === 'granted') {
                return this.showNotification(title, options);
            }
        }

        throw new Error('Notification permission denied');
    }

    async copyToClipboard(text) {
        if (!navigator.clipboard) {
            // Fallback for older browsers
            const textArea = document.createElement('textarea');
            textArea.value = text;
            document.body.appendChild(textArea);
            textArea.select();
            document.execCommand('copy');
            document.body.removeChild(textArea);
            return;
        }

        await navigator.clipboard.writeText(text);
    }

    async readFromClipboard() {
        if (!navigator.clipboard) {
            throw new Error('Clipboard API not supported');
        }

        return await navigator.clipboard.readText();
    }

    async getFileSystemAccess() {
        if (!('showDirectoryPicker' in window)) {
            throw new Error('File System Access API not supported');
        }

        return await window.showDirectoryPicker();
    }

    async registerServiceWorker() {
        if ('serviceWorker' in navigator) {
            try {
                const registration = await navigator.serviceWorker.register('/service-worker.js');
                console.log('Service Worker registered:', registration.scope);
                return registration;
            } catch (error) {
                console.error('Service Worker registration failed:', error);
                throw error;
            }
        }
    }

    setupInstallPrompt() {
        let deferredPrompt;

        window.addEventListener('beforeinstallprompt', (e) => {
            e.preventDefault();
            deferredPrompt = e;

            // Show install button
            this.showInstallButton(deferredPrompt);
        });

        window.addEventListener('appinstalled', () => {
            console.log('PWA was installed');
            this.hideInstallButton();
            deferredPrompt = null;
        });
    }

    async installPWA() {
        if (deferredPrompt) {
            deferredPrompt.prompt();
            const { outcome } = await deferredPrompt.userChoice;
            console.log(`User response to the install prompt: ${outcome}`);
            deferredPrompt = null;
        }
    }

    // Utility methods
    getBrowserInfo() {
        const ua = navigator.userAgent;
        let browser = 'Unknown';

        if (ua.includes('Chrome')) browser = 'Chrome';
        else if (ua.includes('Firefox')) browser = 'Firefox';
        else if (ua.includes('Safari')) browser = 'Safari';
        else if (ua.includes('Edge')) browser = 'Edge';
        else if (ua.includes('Opera')) browser = 'Opera';

        return {
            browser,
            version: this.getBrowserVersion(ua, browser),
            userAgent: ua,
            platform: navigator.platform,
            language: navigator.language,
            cookieEnabled: navigator.cookieEnabled,
            onLine: navigator.onLine,
            hardwareConcurrency: navigator.hardwareConcurrency,
            deviceMemory: navigator.deviceMemory,
            maxTouchPoints: navigator.maxTouchPoints
        };
    }

    getBrowserVersion(ua, browser) {
        const versionRegex = {
            Chrome: /Chrome\/(\d+)/,
            Firefox: /Firefox\/(\d+)/,
            Safari: /Version\/(\d+)/,
            Edge: /Edge\/(\d+)/,
            Opera: /Opera\/(\d+)/
        };

        const regex = versionRegex[browser];
        if (regex) {
            const match = ua.match(regex);
            return match ? match[1] : 'Unknown';
        }

        return 'Unknown';
    }

    isPWAInstalled() {
        return window.matchMedia('(display-mode: standalone)').matches ||
               window.navigator.standalone === true;
    }

    getNetworkInfo() {
        return {
            online: navigator.onLine,
            connection: navigator.connection ? {
                effectiveType: navigator.connection.effectiveType,
                downlink: navigator.connection.downlink,
                rtt: navigator.connection.rtt,
                saveData: navigator.connection.saveData
            } : null
        };
    }

    getScreenInfo() {
        return {
            width: screen.width,
            height: screen.height,
            availWidth: screen.availWidth,
            availHeight: screen.availHeight,
            colorDepth: screen.colorDepth,
            pixelDepth: screen.pixelDepth
        };
    }

    getStorageInfo() {
        if ('storage' in navigator && 'estimate' in navigator.storage) {
            return navigator.storage.estimate();
        }
        return Promise.resolve({ quota: 0, usage: 0 });
    }

    // Performance monitoring
    measureWebVitals() {
        if (typeof PerformanceObserver === 'undefined') {
            return;
        }

        // Largest Contentful Paint
        const lcpObserver = new PerformanceObserver((list) => {
            const entries = list.getEntries();
            const lastEntry = entries[entries.length - 1];
            console.log('LCP:', lastEntry.startTime);
        });
        lcpObserver.observe({ entryTypes: ['largest-contentful-paint'] });

        // First Input Delay
        const fidObserver = new PerformanceObserver((list) => {
            const entries = list.getEntries();
            entries.forEach((entry) => {
                console.log('FID:', entry.processingStart - entry.startTime);
            });
        });
        fidObserver.observe({ entryTypes: ['first-input'] });

        // Cumulative Layout Shift
        const clsObserver = new PerformanceObserver((list) => {
            let clsValue = 0;
            const entries = list.getEntries();
            entries.forEach((entry) => {
                if (!entry.hadRecentInput) {
                    clsValue += entry.value;
                }
            });
            console.log('CLS:', clsValue);
        });
        clsObserver.observe({ entryTypes: ['layout-shift'] });
    }

    // Error handling
    setupErrorHandling() {
        window.addEventListener('error', (event) => {
            console.error('Global error:', event.error);
            this.reportError(event.error);
        });

        window.addEventListener('unhandledrejection', (event) => {
            console.error('Unhandled promise rejection:', event.reason);
            this.reportError(event.reason);
        });
    }

    async reportError(error) {
        // Report error to analytics service
        try {
            await fetch('/api/errors', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    message: error.message,
                    stack: error.stack,
                    url: window.location.href,
                    userAgent: navigator.userAgent,
                    timestamp: new Date().toISOString()
                })
            });
        } catch (reportError) {
            console.error('Failed to report error:', reportError);
        }
    }
}

// Initialize web platform service
const webPlatformService = new WebPlatformService();

// Export for use in Flutter
window.webPlatformService = webPlatformService;
```

---

## 🔐 **Web Security Features**

### **Content Security Policy**

Comprehensive CSP configuration:

```html
<meta http-equiv="Content-Security-Policy" content="
    default-src 'self';
    script-src 'self' 'unsafe-eval' 'unsafe-inline' https://www.gstatic.com https://www.google-analytics.com https://api.katyaairechainmesh.com;
    style-src 'self' 'unsafe-inline' https://fonts.googleapis.com;
    img-src 'self' data: https: blob:;
    font-src 'self' data: https://fonts.gstatic.com;
    connect-src 'self' https: wss: blob: data:;
    media-src 'self' data: blob: https:;
    object-src 'none';
    base-uri 'self';
    form-action 'self';
    frame-ancestors 'none';
    frame-src 'self' https:;
    child-src 'self' blob:;
    worker-src 'self' blob:;
    manifest-src 'self';
    prefetch-src 'self' https:;
    navigate-to 'self' https:;
">
```

### **Security Headers**

Comprehensive security headers configuration:

```javascript
// Security headers for web server
const securityHeaders = {
    // HTTPS enforcement
    'Strict-Transport-Security': 'max-age=31536000; includeSubDomains; preload',

    // XSS protection
    'X-Content-Type-Options': 'nosniff',
    'X-Frame-Options': 'DENY',
    'X-XSS-Protection': '1; mode=block',

    // Content Security Policy
    'Content-Security-Policy': "default-src 'self'; script-src 'self' 'unsafe-eval' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self' data:; connect-src 'self' https: wss:; media-src 'self' data:; object-src 'none'; base-uri 'self'; form-action 'self'; frame-ancestors 'none';",

    // Referrer policy
    'Referrer-Policy': 'strict-origin-when-cross-origin',

    // Permissions policy
    'Permissions-Policy': 'camera=(), microphone=(), geolocation=(), payment=(), usb=(), bluetooth=(), magnetometer=(), accelerometer=(), gyroscope=()',

    // Cross-origin policies
    'Cross-Origin-Embedder-Policy': 'require-corp',
    'Cross-Origin-Opener-Policy': 'same-origin',
    'Cross-Origin-Resource-Policy': 'same-origin',

    // Expect-CT
    'Expect-CT': 'max-age=86400, enforce',

    // Feature policy (deprecated, use Permissions-Policy)
    'Feature-Policy': 'camera none; microphone none; geolocation none; payment none; usb none; bluetooth none; magnetometer none; accelerometer none; gyroscope none'
};
```

---

## 🌐 **Web-Specific Features**

### **Progressive Web App**

1. **Installability**
   - Web App Manifest
   - Service Worker registration
   - HTTPS requirement
   - Install prompt handling

2. **Offline Support**
   - Service Worker caching
   - Background sync
   - Offline fallbacks
   - Cache management

3. **Performance**
   - Web Vitals monitoring
   - Resource optimization
   - Critical rendering path
   - Bundle optimization

4. **Security**
   - Content Security Policy
   - HTTPS enforcement
   - Secure headers
   - Privacy protection

5. **Accessibility**
   - Screen reader support
   - Keyboard navigation
   - High contrast mode
   - Reduced motion support

---

## 🛠️ **Development Setup**

### **Prerequisites**

1. **Modern Web Browser**: Chrome 80+, Firefox 75+, Safari 13+, Edge 80+
2. **Flutter SDK**: With web support enabled
3. **Web Server**: Any HTTPS-enabled web server
4. **SSL Certificate**: Valid SSL certificate for HTTPS
5. **Build Tools**: Node.js, npm for additional tooling

### **Build Configuration**

```bash
# Navigate to web directory
cd web

# Install development dependencies
npm install

# Build for production
flutter build web --release --web-renderer html

# Build with additional optimizations
flutter build web --release --web-renderer html --dart-define=FLUTTER_WEB_USE_SKIA=true

# Enable PWA features
flutter build web --release --pwa-strategy=offline-first

# Build with service worker
flutter build web --release --web-renderer canvaskit --dart-define=FLUTTER_WEB_USE_SKIA=true
```

### **Development Server**

```bash
# Start Flutter web development server
flutter run -d chrome

# Start with specific configuration
flutter run -d chrome --web-renderer html --web-port 3000

# Enable debugging
flutter run -d chrome --debug --web-port 3000 --web-enable-expression-evaluation
```

### **Deployment**

```bash
# Build for deployment
flutter build web --release

# Deploy to static hosting
# Upload contents of build/web/ to your web server

# Configure web server
# Ensure proper MIME types
# Enable gzip compression
# Set up security headers
# Configure caching headers
```

---

## 🧪 **Testing**

### **Web Testing**

```bash
# Run web tests
flutter test --platform chrome

# Run PWA tests
npm run test:pwa

# Run accessibility tests
npm run test:a11y

# Run performance tests
npm run test:performance
```

### **Browser Testing**

1. **Cross-browser Testing**: Test on Chrome, Firefox, Safari, Edge
2. **Mobile Testing**: Test on mobile browsers and devices
3. **PWA Testing**: Test installability and offline functionality
4. **Security Testing**: Test security headers and HTTPS
5. **Performance Testing**: Test Core Web Vitals and loading speed

---

## 📦 **Deployment**

### **Static Hosting**

1. **Netlify**: Deploy with form handling and functions
2. **Vercel**: Deploy with edge functions and optimization
3. **GitHub Pages**: Free static hosting with custom domains
4. **Firebase Hosting**: Google's hosting with CDN and SSL
5. **AWS S3 + CloudFront**: Scalable hosting with CDN

### **Traditional Hosting**

1. **Apache**: Configure with Flutter web requirements
2. **Nginx**: High-performance web server configuration
3. **Node.js**: Custom server with additional features
4. **Docker**: Containerized deployment
5. **CDN**: Global content delivery network

---

## 🔧 **Troubleshooting**

### **Common Issues**

1. **Build Failures**
   - Check Flutter web support: `flutter config --enable-web`
   - Verify Chrome installation
   - Clear build cache: `flutter clean`

2. **PWA Issues**
   - Ensure HTTPS for service worker
   - Check manifest.json validity
   - Verify icon sizes and formats

3. **Performance Issues**
   - Enable canvasKit renderer for better performance
   - Optimize asset loading
   - Implement proper caching strategies

### **Debug Information**

```javascript
// Enable debug logging
console.log('Web Platform Debug Info');
console.log('Browser:', navigator.userAgent);
console.log('Platform:', navigator.platform);
console.log('PWA Installed:', window.matchMedia('(display-mode: standalone)').matches);
console.log('Service Worker:', 'serviceWorker' in navigator);
console.log('Network:', navigator.onLine ? 'Online' : 'Offline');

// Performance metrics
if (typeof PerformanceObserver !== 'undefined') {
    const observer = new PerformanceObserver((list) => {
        console.log('Performance entries:', list.getEntries());
    });
    observer.observe({ entryTypes: ['navigation', 'paint', 'measure'] });
}
```

---

## 📚 **Additional Resources**

- [Progressive Web Apps](https://web.dev/progressive-web-apps/)
- [Web App Manifest](https://web.dev/web-app-manifest/)
- [Service Workers](https://web.dev/service-workers/)
- [Core Web Vitals](https://web.dev/vitals/)
- [Content Security Policy](https://web.dev/csp/)
- [Flutter Web](https://docs.flutter.dev/development/platform-integration/web)

---

## 🎯 **Next Steps**

1. **Complete Testing**: Test on all major browsers and devices
2. **Performance Optimization**: Optimize Core Web Vitals
3. **PWA Enhancement**: Add more PWA features
4. **SEO Optimization**: Improve search engine optimization
5. **Analytics Integration**: Set up comprehensive analytics

---

## 📞 **Support**

For web platform specific issues:

- **Flutter Web Issues**: [Flutter Web GitHub](https://github.com/flutter/flutter/issues)
- **PWA Issues**: [Web.dev](https://web.dev/)
- **Browser Issues**: Browser developer documentation
- **Platform Integration**: [Flutter Discord](https://discord.gg/flutter)

---

**🎉 Web Platform Implementation Complete!**

The Web platform is now fully configured with modern PWA capabilities, security features, and production-ready web application support for the Katya AI REChain Mesh application.
