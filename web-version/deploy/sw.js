const CACHE_NAME = 'xo-arena-v1';
const urlsToCache = [
  '/',
  '/index.html',
  '/css/style.css',
  '/js/game.js',
  '/js/utils/constants.js',
  '/js/utils/soundManager.js',
  '/js/utils/statistics.js',
  '/js/components/Board.js',
  '/js/components/Timer.js',
  '/js/components/ScoreDisplay.js',
  '/js/components/AI.js',
  '/js/scenes/BootScene.js',
  '/js/scenes/MenuScene.js',
  '/js/scenes/GameScene.js',
  '/js/scenes/GameOverScene.js'
];

// Install event
self.addEventListener('install', event => {
  console.log('Service Worker: Installing...');
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => {
        console.log('Service Worker: Caching files');
        return cache.addAll(urlsToCache);
      })
      .catch(error => {
        console.log('Service Worker: Error caching files', error);
      })
  );
});

// Activate event
self.addEventListener('activate', event => {
  console.log('Service Worker: Activating...');
  event.waitUntil(
    caches.keys().then(cacheNames => {
      return Promise.all(
        cacheNames.map(cacheName => {
          if (cacheName !== CACHE_NAME) {
            console.log('Service Worker: Deleting old cache', cacheName);
            return caches.delete(cacheName);
          }
        })
      );
    })
  );
});

// Fetch event
self.addEventListener('fetch', event => {
  event.respondWith(
    caches.match(event.request)
      .then(response => {
        // Return cached version or fetch from network
        return response || fetch(event.request);
      })
      .catch(() => {
        // Return offline page if both cache and network fail
        if (event.request.destination === 'document') {
          return caches.match('/index.html');
        }
      })
  );
});

// Background sync for offline functionality
self.addEventListener('sync', event => {
  if (event.tag === 'background-sync') {
    console.log('Service Worker: Background sync triggered');
    // Handle background sync
  }
});

// Push notification handling
self.addEventListener('push', event => {
  const options = {
    body: 'XO Arena - Nova igra je spremna!',
    icon: '/assets/images/icon-192.png',
    badge: '/assets/images/icon-192.png',
    vibrate: [100, 50, 100],
    data: {
      dateOfArrival: Date.now(),
      primaryKey: 1
    },
    actions: [
      {
        action: 'explore',
        title: 'Igraj sada',
        icon: '/assets/images/icon-192.png'
      },
      {
        action: 'close',
        title: 'Zatvori',
        icon: '/assets/images/icon-192.png'
      }
    ]
  };

  event.waitUntil(
    self.registration.showNotification('XO Arena', options)
  );
});

// Notification click handling
self.addEventListener('notificationclick', event => {
  console.log('Service Worker: Notification clicked');
  
  event.notification.close();

  if (event.action === 'explore') {
    event.waitUntil(
      clients.openWindow('/')
    );
  }
});
