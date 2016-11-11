const container = document.querySelector('#content')
var tmpl=function(a,b){for(var g,h,c=/<%(.+?)%>/g,d=/(^( )?(var|if|for|else|switch|case|break|{|}|;))(.*)?/g,e="with(obj) { var r=[];\n",f=0,i=function(a,b){return e+=b?a.match(d)?a+"\n":"r.push("+a+");\n":""!=a?'r.push("'+a.replace(/"/g,'\\"')+'");\n':"",i};h=c.exec(a);)i(a.slice(f,h.index))(h[1],!0),f=h.index+h[0].length;i(a.substr(f,a.length-f)),e=(e+'return r.join(""); }').replace(/[\r\t\n]/g," ");try{g=new Function("obj",e).apply(b,[b])}catch(a){console.error("'"+a.message+"'"," in \n\nCode:\n",e,"\n")}return g};

function loadTemplate(path) {
  return fetch("/public/templates/" + path)
          .then(resp => resp.text())
          .then(content => (obj) => tmpl(content, obj || {}))
}
function updateContent(content, cb) {
  container.innerHTML = content;
  if (typeof cb === 'function') cb();
}

loadTemplate("search.html")
  .then(content => updateContent(content({}), () => {
                    document.querySelector('#searchForm')
                      .addEventListener('submit', search)
                  }));

function search(evt) {
  evt.preventDefault();

  loadTemplate("item.html")
  .then(template => {
    const form = new FormData(this);
    fetch('/search', {
        method: 'POST',
        body: form
      })
      .then(res => res.json())
      .then(json => json.businesses)
      .then(biz => biz.map(template))
      .then(list => updateContent(list.join("")))
      .catch(err => {
        console.log('err ->', err);
      })
  })
}