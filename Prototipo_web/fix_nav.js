const fs = require('fs');
const files = ['settings.html', 'updates.html', 'installed.html', 'about.html', 'category.html'];

for (const file of files) {
    if (!fs.existsSync(file)) continue;
    let content = fs.readFileSync(file, 'utf-8');
    
    // Check if it already has Navegação
    if (!content.includes('>Navegação</div>')) {
        content = content.replace(
            /<div class="space-y-1" id="nav-group-main">\s*<!-- Rendered by JS -->/,
            `<div class="space-y-1" id="nav-group-main">
                        <div class="px-3 pb-1 text-[11px] font-bold uppercase tracking-wider text-slate-400">Navegação</div>`
        );
        fs.writeFileSync(file, content, 'utf-8');
        console.log('Fixed ' + file);
    }
}
