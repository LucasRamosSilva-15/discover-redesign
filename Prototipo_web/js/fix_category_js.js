const fs = require('fs');
const path = require('path');

const fileTeste = path.join('./Prototipo_web', 'teste.html');
const fileCat = path.join('./Prototipo_web', 'category.html');

const contentTeste = fs.readFileSync(fileTeste, 'utf-8');
let contentCat = fs.readFileSync(fileCat, 'utf-8');

// 1. Extract the clean renderNav functions and renderNav calls from teste.html
const scriptRegex = /<script>([\s\S]*?)<\/script>/;
const matchScript = contentTeste.match(scriptRegex);

if (matchScript) {
    let baseScript = matchScript[1];
    
    // Remove the renderApps call at the end of teste.html's script since we will render our own
    baseScript = baseScript.replace(/renderApps\('grid-destaques'[\s\S]*$/, "");

    // 2. Add our JSON DB and logic
    const customLogic = `
        const categoriesDB = {
            web: {
                title: "Internet",
                subtitle: "Navegadores, clientes de email, e ferramentas de rede.",
                gradient: "from-sky-500 to-blue-700",
                icon: "cat-web",
                apps: [
                    { title: 'Firefox', desc: 'Navegador Web Mozilla', bgClass: 'bg-white', iconClass: 'text-orange-500', icon: 'app-firefox', tag: 'Flatpak', tagClass: 'bg-sky-50 text-sky-600 border border-sky-100', installed: true, stars: '★★★★☆', rating: '4.8' },
                    { title: 'Thunderbird', desc: 'Cliente de Email e Notícias', bgClass: 'bg-white', iconClass: 'text-blue-500', icon: 'app-firefox', tag: 'Nativo', tagClass: 'bg-emerald-50 text-emerald-600 border border-emerald-100', installed: false, stars: '★★★★☆', rating: '4.7' }
                ]
            },
            sys: {
                title: "Sistema",
                subtitle: "Ferramentas de administração e utilitários base do KDE.",
                gradient: "from-slate-600 to-slate-800",
                icon: "cat-sys",
                apps: [
                    { title: 'Discover', desc: 'Gerenciador de software', bgClass: 'bg-blue-500', iconClass: 'text-white', icon: 'cat-sys', tag: 'Nativo', tagClass: 'bg-emerald-50 text-emerald-600 border border-emerald-100', installed: true, stars: '★★★★★', rating: '5.0' },
                    { title: 'Dolphin', desc: 'Gerenciador de arquivos', bgClass: 'bg-sky-500', iconClass: 'text-white', icon: 'cat-office', tag: 'Nativo', tagClass: 'bg-emerald-50 text-emerald-600 border border-emerald-100', installed: true, stars: '★★★★☆', rating: '4.9' },
                    { title: 'Console', desc: 'Emulador de Terminal', bgClass: 'bg-slate-900', iconClass: 'text-white', icon: 'cat-dev', tag: 'Nativo', tagClass: 'bg-emerald-50 text-emerald-600 border border-emerald-100', installed: true, stars: '★★★★☆', rating: '4.8' }
                ]
            },
            gfx: {
                title: "Gráficos",
                subtitle: "Edição de imagem, modelagem 3D e pintura digital.",
                gradient: "from-purple-500 to-pink-600",
                icon: "cat-gfx",
                apps: [
                    { title: 'Krita', desc: 'Pintura digital profissional', bgClass: 'bg-pink-100', iconClass: 'text-pink-600', icon: 'cat-gfx', tag: 'Flatpak', tagClass: 'bg-sky-50 text-sky-600 border border-sky-100', installed: false, stars: '★★★★★', rating: '4.9' }
                ]
            },
            dev: {
                title: "Desenvolvimento",
                subtitle: "IDEs, editores de código e ferramentas para desenvolvedores.",
                gradient: "from-indigo-600 to-blue-800",
                icon: "cat-dev",
                apps: [
                    { title: 'Kate', desc: 'Editor de texto avançado', bgClass: 'bg-slate-100', iconClass: 'text-slate-700', icon: 'cat-dev', tag: 'Nativo', tagClass: 'bg-emerald-50 text-emerald-600 border border-emerald-100', installed: true, stars: '★★★★☆', rating: '4.8' }
                ]
            }
        };

        const urlParams = new URLSearchParams(window.location.search);
        const catId = urlParams.get('id') || 'sys';
        const categoryData = categoriesDB[catId] || {
            title: "Categoria em Construção",
            subtitle: "Esta categoria será populada em breve.",
            gradient: "from-slate-400 to-slate-500",
            icon: "cat-todos",
            apps: []
        };

        // Render Hero
        const catHero = document.getElementById('cat-hero');
        if(catHero) catHero.className = \`relative overflow-hidden rounded-2xl bg-gradient-to-r \${categoryData.gradient} text-white p-6 shadow-lg\`;
        
        const catTitle = document.getElementById('cat-title');
        if(catTitle) catTitle.textContent = categoryData.title;
        
        const catSub = document.getElementById('cat-subtitle');
        if(catSub) catSub.textContent = categoryData.subtitle;
        
        const catIcon = document.getElementById('cat-icon');
        if(catIcon) catIcon.innerHTML = \`<use href="#\${categoryData.icon}" />\`;
        
        const catIconBg = document.getElementById('cat-icon-bg');
        if(catIconBg) catIconBg.innerHTML = \`<use href="#\${categoryData.icon}" />\`;

        // Render Apps (Safely)
        if (typeof renderApps === 'function') {
            renderApps('grid-category-apps', categoryData.apps);
        }

        // We also need to highlight the correct category in the sidebar.
        // We can do this AFTER renderNav has run, by finding the a tag with the matching href.
        setTimeout(() => {
            const links = document.querySelectorAll('#nav-group-categories a');
            links.forEach(link => {
                if (link.getAttribute('href').includes('id=' + catId)) {
                    link.className = 'flex items-center justify-between px-3 py-2 rounded-xl text-xs group transition-colors font-semibold bg-plasma-500 text-white shadow-sm shadow-plasma-500/30';
                    const svg = link.querySelector('svg');
                    if (svg) svg.className = 'w-4 h-4';
                } else {
                    link.className = 'flex items-center justify-between px-3 py-2 rounded-xl text-xs group transition-colors font-medium text-slate-700 hover:bg-slate-200/60';
                    const svg = link.querySelector('svg');
                    if (svg) svg.className = 'w-4 h-4 text-slate-500';
                }
            });
        }, 50);
`;

    // Now replace the <script> block in category.html entirely.
    contentCat = contentCat.replace(/<script>[\s\S]*?<\/script>/, `<script>\n${baseScript}\n${customLogic}\n    </script>`);
    
    fs.writeFileSync(fileCat, contentCat, 'utf-8');
    console.log('Fixed category.html script completely!');
} else {
    console.log('Could not extract script from teste.html');
}
