const fs = require('fs');
const files = ['app-details.html', 'settings.html', 'updates.html', 'installed.html', 'about.html', 'category.html', 'teste.html'];

const newRenderNav = `        const renderNav = (containerId, items) => {
            const el = document.getElementById(containerId);
            items.forEach(item => {
                let badgeHtml = '';
                if (item.badge) {
                    badgeHtml = typeof item.badge === 'string' 
                        ? \`<span class="px-2 py-0.5 text-[10px] font-semibold \${item.active ? 'bg-white/20 text-white' : 'bg-slate-200 text-slate-700'} rounded-full">\${item.badge}</span>\`
                        : \`<div class="flex flex-col"><span>\${item.label}</span><span class="text-[10px] text-plasma-600 font-normal">\${item.badge.text}</span></div><span class="w-2 h-2 rounded-full bg-plasma-500 animate-ping"></span>\`;
                }
                const labelHtml = item.badge && typeof item.badge !== 'string' ? badgeHtml : \`<span>\${item.label}</span>\`;
                
                el.innerHTML += \`
                    <a href="#" class="flex items-center justify-between px-3 py-2 rounded-xl text-xs group transition-colors \${item.active ? 'font-semibold bg-plasma-500 text-white shadow-sm shadow-plasma-500/30' : 'font-medium text-slate-700 hover:bg-slate-200/60'}">
                        <div class="flex items-center gap-3">
                            <svg class="w-4 h-4 \${item.active ? '' : (item.iconSpin ? 'text-plasma-500 animate-spin' : 'text-slate-500')}"><use href="#\${item.icon}"/></svg>
                            \${labelHtml}
                        </div>
                        \${item.badge && typeof item.badge === 'string' ? badgeHtml : ''}
                        \${item.hasSubmenu ? '<svg class="w-3.5 h-3.5 ' + (item.active ? 'text-white/70' : 'text-slate-400 group-hover:text-slate-600') + ' transition-colors"><use href="#icon-forward"/></svg>' : ''}
                    </a>\`;
            });
        };`;

for (const file of files) {
    if (!fs.existsSync(file)) continue;
    let content = fs.readFileSync(file, 'utf-8');
    
    // Replace icon-settings with nav-config
    content = content.replace(/{ icon: 'icon-settings', label: 'Configurações' }/g, "{ icon: 'nav-config', label: 'Configurações' }");
    
    // Replace the renderNav function
    // Use regex to match the old renderNav completely
    const regex = /const renderNav = \(containerId, items\) => \{[\s\S]*?el\.innerHTML \+= `[\s\S]*?`;\s*\}\);\s*\};/g;
    content = content.replace(regex, newRenderNav);
    
    fs.writeFileSync(file, content, 'utf-8');
    console.log('Fixed ' + file);
}
