(() => {
  const removeLoader = () => {
    const el = document.getElementById('loading_indicator');
    if (el) el.remove();
  };

  window.addEventListener('flutter-first-frame', removeLoader);
  window.addEventListener('load', () => {
    setTimeout(removeLoader, 12000);
  });
})();