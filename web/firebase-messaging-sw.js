importScripts("https://www.gstatic.com/firebasejs/9.6.10/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.6.10/firebase-messaging-compat.js");

const firebaseConfig = {
  apiKey: "AIzaSyCbZHjGvtJwFl-IrTCdimslfTCGe4GPAG4",
  authDomain: "fither-e7a36.firebaseapp.com",
  projectId: "fither-e7a36",
  storageBucket: "fither-e7a36.firebasestorage.app",
  messagingSenderId: "591042819842",
  appId: "1:591042819842:web:5bb1f96304b2b82f77f41b",
  measurementId: "G-HR4HD798HX"
};

firebase.initializeApp(firebaseConfig);
const messaging = firebase.messaging();
//messaging.onBackgroundMessage((message) => {
// console.log("onBackgroundMessage", message);
//});
messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
//    icon: '/firebase-logo.png'
  };


  console.log('notificationTitle', notificationTitle);
  console.log('notificationOptions', notificationOptions);

  self.registration.showNotification(notificationTitle, notificationOptions)
    .then(() => console.log('Notification displayed successfully'))
    .catch((error) => console.error('Failed to display notification:', error));
});
