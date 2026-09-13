const fs = require('fs');
const path = require('path');

const file = path.join('./Prototipo_web', 'category.html');
let content = fs.readFileSync(file, 'utf-8');

// The dynamic logic to append to <script>
const scriptLogic = `
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
                    { title: 'Dolphin', desc: 'Gerenciador de arquivos', bgClass: 'bg-sky-500', iconClass: 'text-white', icon: 'cat-office', tag: 'Nativo', tagClass: 'bg-emerald-50 text-emerald-600 border border-emerald-100', installed: true, stars: '★★★★☆', rating: '4.9' }
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
            title: "Categoria Desconhecida",
            subtitle: "Nenhum aplicativo encontrado aqui.",
            gradient: "from-slate-400 to-slate-500",
            icon: "cat-todos",
            apps: []
        };

        // Render Hero
        document.getElementById('cat-hero').className = \`relative overflow-hidden rounded-2xl bg-gradient-to-r \${categoryData.gradient} text-white p-6 shadow-lg\`;
        document.getElementById('cat-title').textContent = categoryData.title;
        document.getElementById('cat-subtitle').textContent = categoryData.subtitle;
        document.getElementById('cat-icon').innerHTML = \`<use href="#\${categoryData.icon}" />\`;

        // Render Apps
        renderApps('grid-category-apps', categoryData.apps);

        // Update active state in Sidebar logic
        // We patch the global renderNav to set active dynamically for categories
        const originalRenderNav = renderNav;
        renderNav = function(containerId, items) {
            if (containerId === 'nav-group-categories') {
                items.forEach(i => i.active = (i.id === catId));
            }
            originalRenderNav(containerId, items);
        };
`;

// Inject into category.html
// 1. Replace the static hero
const heroRegex = /<!-- Category Header -->[\s\S]*?(?=<!-- App Grid -->)/;
const newHero = `<!-- Category Header -->
                <div id="cat-hero" class="relative overflow-hidden rounded-2xl bg-gradient-to-r from-slate-600 to-slate-800 text-white p-6 shadow-lg">
                    <div class="absolute -right-4 -bottom-8 opacity-10 pointer-events-none">
                        <svg class="w-64 h-64 text-white" fill="currentColor" viewBox="0 0 24 24"><use href="#cat-sys" id="cat-icon-bg" /></svg>
                    </div>
                    <div class="relative z-10 max-w-xl flex items-center gap-5">
                        <div class="w-16 h-16 rounded-2xl bg-white/10 backdrop-blur-md flex items-center justify-center shrink-0 border border-white/20 shadow-inner">
                            <svg class="w-8 h-8 text-white"><use href="#cat-sys" id="cat-icon"/></svg>
                        </div>
                        <div>
                            <h2 class="text-2xl font-bold tracking-tight text-white mb-1" id="cat-title">Sistema</h2>
                            <p class="text-slate-200 text-sm leading-relaxed" id="cat-subtitle">Ferramentas essenciais para o sistema operacional.</p>
                        </div>
                    </div>
                </div>
                
                `;
content = content.replace(heroRegex, newHero);

// 2. Clear the static grid
const gridRegex = /<div class="grid grid-cols-1 md:grid-cols-2 gap-4" id="grid-category-apps">[\s\S]*?<\/div>/;
content = content.replace(gridRegex, `<div class="grid grid-cols-1 md:grid-cols-2 gap-4" id="grid-category-apps"></div>`);

// 3. Inject JS logic before the renderNav calls
// First, find where renderApps is defined and insert our logic right before the renderNav calls.
const insertionPoint = /renderNav\('nav-group-main'/;
content = content.replace(insertionPoint, scriptLogic + "\n        " + "renderNav('nav-group-main'");

// 4. Remove any static calls to renderApps if they existed in category.html
content = content.replace(/renderApps\('grid-category-apps',[\s\S]*?\]\);/, "");

fs.writeFileSync(file, content, 'utf-8');
console.log('Category HTML made dynamic with JSON database!');

