const fs = require('fs');
const path = require('path');

const fileTeste = path.join('./Prototipo_web', 'teste.html');
const fileCat = path.join('./Prototipo_web', 'category.html');

let content = fs.readFileSync(fileTeste, 'utf-8');

// 1. Replace the <main> block
// Find <main ...> and replace its contents
const mainRegex = /(<main class="flex-1 overflow-y-auto bg-slate-50\/40 p-6 md:p-8 space-y-8">)[\s\S]*?(<\/main>)/;

const newMainContent = `$1
                <!-- Category Header -->
                <div id="cat-hero" class="relative overflow-hidden rounded-2xl bg-gradient-to-r from-slate-600 to-slate-800 text-white p-6 shadow-lg">
                    <div class="absolute -right-4 -bottom-8 opacity-10 pointer-events-none">
                        <svg class="w-64 h-64 text-white" fill="currentColor" viewBox="0 0 24 24"><use href="#cat-sys" id="cat-icon-bg" /></svg>
                    </div>
                    <div class="relative z-10 max-w-xl flex items-center gap-5">
                        <div class="w-16 h-16 rounded-2xl bg-white/10 backdrop-blur-md flex items-center justify-center shrink-0 border border-white/20 shadow-inner">
                            <svg class="w-8 h-8 text-white"><use href="#cat-sys" id="cat-icon"/></svg>
                        </div>
                        <div>
                            <h2 class="text-2xl font-bold tracking-tight text-white mb-1" id="cat-title">Carregando...</h2>
                            <p class="text-slate-200 text-sm leading-relaxed" id="cat-subtitle">Buscando informações da categoria.</p>
                        </div>
                    </div>
                </div>
                
                <!-- App Grid -->
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4" id="grid-category-apps">
                </div>
$2`;

content = content.replace(mainRegex, newMainContent);

// 2. Remove static renderApps calls at the bottom of the script
// They look like: renderApps('grid-mais-popular', [...]); and renderApps('grid-escolha-editor', [...]);
content = content.replace(/renderApps\('grid-mais-popular',[\s\S]*?\]\);/g, "");
content = content.replace(/renderApps\('grid-escolha-editor',[\s\S]*?\]\);/g, "");

// 3. Inject our custom JSON logic right before the closing </script>
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

        // Render Apps
        renderApps('grid-category-apps', categoryData.apps);

        // Highlight Active Category in Sidebar
        setTimeout(() => {
            const links = document.querySelectorAll('#nav-group-categories a');
            links.forEach(link => {
                if (link.getAttribute('href').includes('id=' + catId)) {
                    link.className = 'flex items-center justify-between px-3 py-2 rounded-xl text-xs group transition-colors font-semibold bg-plasma-500 text-white shadow-sm shadow-plasma-500/30';
                    const svg = link.querySelector('svg');
                    if (svg) svg.className = 'w-4 h-4 text-white';
                } else {
                    link.className = 'flex items-center justify-between px-3 py-2 rounded-xl text-xs group transition-colors font-medium text-slate-700 hover:bg-slate-200/60';
                    const svg = link.querySelector('svg');
                    if (svg) svg.className = 'w-4 h-4 text-slate-500';
                }
            });
        }, 50);
`;

// Insert the logic before the final </script> tag
// Since teste.html has TWO script tags, we find the last one by finding the last occurrence of </script>
const lastScriptEnd = content.lastIndexOf('</script>');
content = content.slice(0, lastScriptEnd) + customLogic + '\n    </script>' + content.slice(lastScriptEnd + 9);

fs.writeFileSync(fileCat, content, 'utf-8');
console.log('Rebuilt category.html cleanly from teste.html');
