'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "612a3fcdb2a5dba26b35906825b76074",
"version.json": "d24d516821e482def274b3330c6037c5",
"index.html": "d782cfee8683e92240907e3ce6a79898",
"/": "d782cfee8683e92240907e3ce6a79898",
"main.dart.js": "9503abc88abbb15945dd7745ec288908",
"flutter.js": "f393d3c16b631f36852323de8e583132",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"manifest.json": "bdf50cb13b021e1668ea3b0f72f1bcff",
"assets/AssetManifest.json": "db6f73d9aa1cc60dbf3c7303692170a4",
"assets/NOTICES": "825d2943956388253fc21a1c81b78c86",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/AssetManifest.bin.json": "7e88505ba0cd1808b526d7ddbb868d47",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "e986ebe42ef785b27164c36a9abc7818",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin": "2891ba65e1bb1e7826dfd8cce6406fa9",
"assets/fonts/MaterialIcons-Regular.otf": "8ea08ea2444cc58ec5807fd7669e488f",
"assets/assets/body_1.png": "446bac8205c0eee3d74fbec27961f357",
"assets/assets/body_3.png": "d669b4c7cc7aa5369ed02579c6ba9067",
"assets/assets/novelresearcher.png": "68a56074f05ea42b93c4922f98e1d177",
"assets/assets/body_10.png": "93d2607d5ca9c398daf4ac7061cad54a",
"assets/assets/body_2.png": "81fb7c13f1c71ebf0c289db4427aace6",
"assets/assets/body_6.png": "ab48c77c53d8e2cb2354f856465cc5f4",
"assets/assets/body_7.png": "7c4839c4e097c9fa4e6522110171ea4b",
"assets/assets/body_5.png": "88ce5bcae0a4f80a9ac5e6fce7b04b4d",
"assets/assets/main.png": "f68e5a78746cb505879bc42bbc5f28e8",
"assets/assets/body_4.png": "ee247fe4a10b5a1059d70c841faae4e3",
"assets/assets/body_default.png": "0e676077585c8bab4be65ee10e4cf4ed",
"assets/assets/head_9.png": "0f7769ba682941eabe14e517f75f8231",
"assets/assets/head_8.png": "e7c640fdb9ac8030679f52f1c4302805",
"assets/assets/head_default.png": "77db91487fea6651eeb39254c3874225",
"assets/assets/tool_8.png": "25c0206d9c96dbbd53f96188b90783a9",
"assets/assets/tool_9.png": "f8267567f2af41d92d8d6e5651075019",
"assets/assets/webtooneditor.png": "c0ca31d80213267f4f0d46587da5e3bd",
"assets/assets/head_10.png": "91bdfc0cface50b08a4f48263d049336",
"assets/assets/scenarioeditor.png": "6dd684711b83fa6dc9454feb8ecb27e6",
"assets/assets/tool_4.png": "252e110cd916e1655391446fe22fcb2e",
"assets/assets/head_1.png": "5eff1cc29a08f5799f732fc980f5f7c8",
"assets/assets/tool_5.png": "b0731d732bd375d8b060ccd80fd5be2f",
"assets/assets/tool_7.png": "5dad6796710a977a244c7c8faa80eae5",
"assets/assets/head_3.png": "ec848d806e4e0ff39c2e9bcb4542cb53",
"assets/assets/head_2.png": "bb0d8f1aeec74f042910687738e7e973",
"assets/assets/tool_6.png": "bf73ae979b6472529e1a526e1bfe5ade",
"assets/assets/chair.png": "091d34ca9b55290b171ee25b56734c5d",
"assets/assets/tool_2.png": "152f198cdc5f761259aa73521458e121",
"assets/assets/head_6.png": "f652db102d0f5f929a0652025fee139b",
"assets/assets/head_7.png": "23d4fbf55e2093724842fd848eabddd0",
"assets/assets/tool_3.png": "ee1c496158833b54c95834bcde7c9777",
"assets/assets/tool_1.png": "13e70efb31d8a2f155c262bc1a15b2cd",
"assets/assets/head_5.png": "5e8dcf9a23ea80b15a6bdf50ec3cb1ae",
"assets/assets/head_4.png": "17955af30d05a8ff5daedbe66343822a",
"assets/assets/webtoonartist.png": "fd01a7d7d2622e568702161839906d60",
"assets/assets/body_9.png": "d7e515c8bc50f1e255af17fb7a487c67",
"assets/assets/body_8.png": "ba3609f419b45acb327052e86f79b0ed",
"assets/assets/tool_default.png": "1d5ac8088f8922b59ecca51c95483b51",
"canvaskit/skwasm.js": "694fda5704053957c2594de355805228",
"canvaskit/skwasm.js.symbols": "262f4827a1317abb59d71d6c587a93e2",
"canvaskit/canvaskit.js.symbols": "48c83a2ce573d9692e8d970e288d75f7",
"canvaskit/skwasm.wasm": "9f0c0c02b82a910d12ce0543ec130e60",
"canvaskit/chromium/canvaskit.js.symbols": "a012ed99ccba193cf96bb2643003f6fc",
"canvaskit/chromium/canvaskit.js": "671c6b4f8fcc199dcc551c7bb125f239",
"canvaskit/chromium/canvaskit.wasm": "b1ac05b29c127d86df4bcfbf50dd902a",
"canvaskit/canvaskit.js": "66177750aff65a66cb07bb44b8c6422b",
"canvaskit/canvaskit.wasm": "1f237a213d7370cf95f443d896176460",
"canvaskit/skwasm.worker.js": "89990e8c92bcb123999aa81f7e203b1c"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
