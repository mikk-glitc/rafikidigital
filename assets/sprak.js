/* Språkval for rafikidigital.no: nynorsk (nn), engelsk (en) og swahili (sw).
   Valet blir hugsa (localStorage), så det følgjer med frå side til side.
   Elementa merkar ein slik:
     data-t="nøkkel"   byter ut teksten
     data-th="nøkkel"  byter ut innhald med lenkjer o.l. (berre eigne tekstar)
   Teksten som står i HTML-en er nynorsk og blir brukt når nn er valt.
   Kvar side legg omsetjingane sine i window.TEKST = { en: {...}, sw: {...} }. */
(function () {
  var SPRAK = ['nn', 'en', 'sw'];
  var NOKKEL = 'rafiki-sprak';

  function lagra(l) { try { localStorage.setItem(NOKKEL, l); } catch (e) {} }
  function vel() {
    var q = new URLSearchParams(location.search).get('lang');
    if (SPRAK.indexOf(q) > -1) { lagra(q); return q; }
    try { var s = localStorage.getItem(NOKKEL); if (SPRAK.indexOf(s) > -1) return s; } catch (e) {}
    return 'nn';
  }

  var no = vel();

  function t(nokkel) {
    var d = window.TEKST || {};
    return d[no] && d[no][nokkel] != null ? d[no][nokkel] : null;
  }

  function bruk() {
    document.documentElement.lang = no;
    document.querySelectorAll('[data-t]').forEach(function (el) {
      if (el.dataset.o == null) el.dataset.o = el.textContent;
      var v = no === 'nn' ? null : t(el.dataset.t);
      el.textContent = v != null ? v : el.dataset.o;
    });
    document.querySelectorAll('[data-th]').forEach(function (el) {
      if (el.dataset.o == null) el.dataset.o = el.innerHTML;
      var v = no === 'nn' ? null : t(el.dataset.th);
      el.innerHTML = v != null ? v : el.dataset.o;
    });
    if (document.body) {
      if (document.body.dataset.o == null) document.body.dataset.o = document.title;
      var tt = no === 'nn' ? null : t('_tittel');
      document.title = tt != null ? tt : document.body.dataset.o;
    }
    document.querySelectorAll('.sprak button').forEach(function (b) {
      b.setAttribute('aria-pressed', String(b.dataset.lang === no));
    });
    document.querySelectorAll('[data-berre-sprak]').forEach(function (el) {
      el.hidden = el.dataset.berreSprak.split(' ').indexOf(no) === -1;
    });
    document.dispatchEvent(new CustomEvent('sprak', { detail: no }));
  }

  window.Sprak = {
    no: function () { return no; },
    t: t,
    set: function (l) { if (SPRAK.indexOf(l) === -1) return; no = l; lagra(l); bruk(); }
  };

  document.addEventListener('click', function (e) {
    var b = e.target.closest && e.target.closest('.sprak button');
    if (b) window.Sprak.set(b.dataset.lang);
  });

  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', bruk);
  else bruk();
})();
