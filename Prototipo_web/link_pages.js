const fs = require('fs');
const path = require('path');

const dir = './Prototipo_web';
const files = ['teste.html', 'app-details.html', 'settings.html', 'updates.html', 'installed.html', 'about.html', 'category.html'];

for (const filename of files) {
    const file = path.join(dir, filename);
    if (!fs.existsSync(file)) continue;
    let content = fs.readFileSync(file, 'utf-8');
    
    // 1. Update renderNav to use item.href instead of "#"
    content = content.replace(/<a href="#" class="flex items-center justify-between/g, '<a href="${item.href || \'#\'}" class="flex items-center justify-between');

    // 2. Add href to the items in nav-group-main
    content = content.replace(/{ icon: 'nav-inicio', label: 'Início'(.*?) }/g, "{ icon: 'nav-inicio', label: 'Início'$1, href: 'teste.html' }");
    content = content.replace(/{ icon: 'nav-instalado', label: 'Instalado'(.*?) }/g, "{ icon: 'nav-instalado', label: 'Instalado'$1, href: 'installed.html' }");
    content = content.replace(/{ icon: 'nav-atualizacoes', label: 'Atualizações'(.*?) }/g, "{ icon: 'nav-atualizacoes', label: 'Atualizações'$1, href: 'updates.html' }");
    content = content.replace(/{ icon: 'nav-config', label: 'Configurações'(.*?) }/g, "{ icon: 'nav-config', label: 'Configurações'$1, href: 'settings.html' }");
    content = content.replace(/{ icon: 'nav-sobre', label: 'Sobre'(.*?) }/g, "{ icon: 'nav-sobre', label: 'Sobre'$1, href: 'about.html' }");
    
    // 3. Add href to the items in nav-group-categories
    // Since there are many, we can just replace 'cat-sys' to go to category.html
    content = content.replace(/{ icon: 'cat-sys', label: 'Sistema'(.*?) }/g, "{ icon: 'cat-sys', label: 'Sistema'$1, href: 'category.html' }");
    
    // 4. Update App Cards to link to app-details.html
    // If there is renderApps function, update it
    content = content.replace(/<div class="group bg-white rounded-xl p-4/g, '<a href="app-details.html" class="block group bg-white rounded-xl p-4');
    content = content.replace(/<\/div>`\s*;/g, '</a>`;\n'); // close the a tag instead of div if the container was replaced.
    // Wait, replacing </div> with </a> in renderApps is tricky with regex. Let's do it safely.
    // Replace:
    // <div class="group bg-white rounded-xl p-4 border border-slate-200/80 shadow-subtle hover:shadow-card-hover hover:border-slate-300 transition-all flex items-center justify-between">
    // With:
    // <a href="app-details.html" class="group bg-white rounded-xl p-4 border border-slate-200/80 shadow-subtle hover:shadow-card-hover hover:border-slate-300 transition-all flex items-center justify-between text-left">
    
    content = content.replace(
        /<div class="group bg-white rounded-xl p-4 border border-slate-200\/80 shadow-subtle hover:shadow-card-hover hover:border-slate-300 transition-all flex items-center justify-between">/g,
        '<a href="app-details.html" style="text-decoration: none; color: inherit;" class="group bg-white rounded-xl p-4 border border-slate-200/80 shadow-subtle hover:shadow-card-hover hover:border-slate-300 transition-all flex items-center justify-between">'
    );
    
    // The closing div of the app card in renderApps:
    //     ${installButton}
    // </div>`;
    content = content.replace(
        /(\$\{installButton\})\s*<\/div>/g,
        '$1\n                    </a>'
    );
    
    // Also change standalone app cards in updates.html / installed.html
    // In installed.html:
    // <div class="group bg-white rounded-xl p-4 border border-slate-200/80 shadow-sm flex items-center justify-between">
    content = content.replace(
        /<div class="group bg-white rounded-xl p-4 border border-slate-200\/80 shadow-sm flex items-center justify-between">/g,
        '<a href="app-details.html" style="text-decoration: none; color: inherit;" class="group bg-white rounded-xl p-4 border border-slate-200/80 shadow-sm flex items-center justify-between hover:shadow-card-hover transition-all">'
    );
    // Find the corresponding closing divs... 
    // This regex replaces the last </div> before the template literal ends in installed/updates.html?
    // It might be too fragile. Let's write the file out first.

    fs.writeFileSync(file, content, 'utf-8');
    console.log('Linked ' + file);
}
