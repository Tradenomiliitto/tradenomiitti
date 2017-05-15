import autocomplete from 'autocomplete.js';

const autocompletersById = {};

export default function initTypeahead(elm2js, js2elm) {
  elm2js.subscribe(([ id, list, emptyAfter, allowCreation, initialValue ]) => {

    //wait until element is rendered
    let counter = 0;
    const timeoutId = setInterval(function () {
      counter += 1;

      const el = document.getElementById(id);

      if (el) {
        clearTimeout(timeoutId);
        init(el);
      } else if (counter > 10) {
        clearTimeout(timeoutId);
      }
    }, 20);

    function init(element) {
      if (element.classList.contains('aa-input')) {
        autocompletersById[id].autocomplete.setVal('');
        return;
      }

      // http://stackoverflow.com/a/14438954/1517818
      const unique = (value, i, array) => array.indexOf(value) === i;
      const categories = list.map(o => o.category).filter(unique);

      const autocompleter = autocomplete(`#${id}`, {
        hint: false,
        openOnFocus: true,
        minLength: 0
      }, categories.map(category => {
        const categoryOptions = list
              .filter(o => o.category === category)
              .map(o => o.title)
              .sort();
        return {
          source: function (q, cb) {
            const qLower = q.toLowerCase();
            cb(categoryOptions.filter(x => x.toLowerCase().includes(qLower)).map(x => ({ value: x})))
          },
          templates: {
            header: `<h4 class="aa-category">${category}</h4>`,
            suggestion: function(suggestion) {
              var val = suggestion.value;
              return autocomplete.escapeHighlightedString(val);
            }
          }
        }
      }).concat(allowCreation ? {
          source: function (q, cb) {
            q.length > 0
              ? cb([{value: `Lisää "${q}" vaihtoehdoksi`, original: q}])
              : cb([])
          },
          templates: {
            suggestion: function(suggestion) {
              var val = suggestion.value;
              return autocomplete.escapeHighlightedString(val);
            }
          }
      } : []));
      autocompleter.autocomplete.setVal(initialValue);
      autocompletersById[id] = autocompleter;
      autocompleter.on('autocomplete:selected', (ev, suggestion, dataset) => {
        const value = suggestion.original || suggestion.value;
        if (emptyAfter)
          autocompleter.autocomplete.setVal('');
        else
          autocompleter.autocomplete.setVal(value);
        $(element).blur();
        js2elm.send([ value, id ]);
      })

      element.addEventListener('input', () => {
        // if user empties the field, the filter should get lost too
        // without this we only send values to elm side on selection of an
        // option, but there is no selection for nothing selected, hence this
        if (autocompleter.autocomplete.getVal() === '')
          js2elm.send([ '', id ]);
      })
    }
  })
}
