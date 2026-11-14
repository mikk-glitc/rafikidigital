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


  /* Språkknappen ligg fast i hjørnet øvst til høgre og følgjer med på alle sidene. */
  function lagKnapp() {
    if (document.querySelector('.sprakval')) return;
    var st = document.createElement('style');
    st.textContent =
      '.sprakval{position:fixed;top:.75rem;right:.75rem;z-index:50;display:flex;align-items:center;gap:.15rem;padding:.2rem;' +
      'background:rgba(38,56,47,.88);-webkit-backdrop-filter:blur(6px);backdrop-filter:blur(6px);border:1px solid rgba(242,244,241,.3);' +
      'border-radius:999px;box-shadow:0 4px 18px rgba(10,16,20,.25);font-family:"Spectral",Georgia,serif}' +
      '.sprakval svg{width:18px;height:18px;margin:0 .25rem 0 .4rem;color:#C9D6CE;flex:none}' +
      '.sprakval button{font:inherit;font-size:.82rem;font-weight:600;letter-spacing:.05em;color:#F2F4F1;background:transparent;' +
      'border:0;border-radius:999px;min-width:40px;min-height:36px;padding:0 .55rem;cursor:pointer}' +
      '.sprakval button:hover{background:rgba(242,244,241,.12)}' +
      '.sprakval button[aria-pressed="true"]{background:#F2F4F1;color:#26382F}' +
      '.sprakval button:focus-visible{outline:2px solid #C99A4B;outline-offset:1px}' +
      /* gje menyen plass til knappen når han ligg på same rad */
      '@media (min-width:35rem) and (max-width:88rem){.meny .inn{padding-right:12rem !important}}';
    document.head.appendChild(st);
    var d = document.createElement('div');
    d.className = 'sprakval';
    d.setAttribute('role', 'group');
    d.setAttribute('aria-label', 'Språk / Language / Lugha');
    d.innerHTML = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" aria-hidden="true"><circle cx="12" cy="12" r="9"/><path d="M3 12h18M12 3c2.5 2.6 3.8 5.6 3.8 9s-1.3 6.4-3.8 9M12 3c-2.5 2.6-3.8 5.6-3.8 9s1.3 6.4 3.8 9"/></svg>' +
      '<button type="button" data-lang="nn" lang="nn" title="Norsk">NO</button>' +
      '<button type="button" data-lang="en" lang="en" title="English">EN</button>' +
      '<button type="button" data-lang="sw" lang="sw" title="Kiswahili">SW</button>';
    document.body.appendChild(d);
  }

  function bruk() {
    lagKnapp();
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
    document.querySelectorAll('.sprakval button').forEach(function (b) {
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
    var b = e.target.closest && e.target.closest('.sprakval button');
    if (b) window.Sprak.set(b.dataset.lang);
  });

  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', bruk);
  else bruk();
})();
