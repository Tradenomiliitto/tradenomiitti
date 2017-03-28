const ga = window.ga || undefined;
export default function initGoogleAnalytics(port) {
  port.subscribe((path) => {
    ga && ga('set', 'page', path);
    ga && ga('send', 'pageview');
  });
}
