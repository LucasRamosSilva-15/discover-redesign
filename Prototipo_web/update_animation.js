const fs = require('fs');
const path = require('path');

const dir = './Prototipo_web';
const files = ['teste.html', 'app-details.html', 'settings.html', 'updates.html', 'installed.html', 'about.html', 'category.html'];

const oldRenderNavRegex = /const renderNav = \(containerId, items\) => \{[\s\S]*?\}\s*;\s*/;

const newRenderNav = `const renderNav = (containerId, items) => {
            const el = document.getElementById(containerId);
            let html = '';
            items.forEach((item, idx) => {
                const itemId = containerId + '-' + idx;
                let badgeHtml = '';
                if (item.badge) {
                    badgeHtml = typeof item.badge === 'string' 
                        ? \`<span class="px-2 py-0.5 text-[10px] font-semibold \${item.active ? 'bg-white/20 text-white' : 'bg-slate-200 text-slate-700'} rounded-full">\${item.badge}</span>\`
                        : \`<div class="flex flex-col" id="complex-badge-\${itemId}"><span>\${item.label}</span><span class="text-[10px] text-plasma-600 font-normal">\${item.badge.text}</span></div><span id="ping-\${itemId}" class="w-2 h-2 rounded-full bg-plasma-500 animate-ping"></span>\`;
                }
                const labelHtml = item.badge && typeof item.badge !== 'string' ? badgeHtml : \`<span>\${item.label}</span>\`;
                
                html += \`
                    <a href="\${item.href || '#'}" class="flex items-center justify-between px-3 py-2 rounded-xl text-xs group transition-colors \${item.active ? 'font-semibold bg-plasma-500 text-white shadow-sm shadow-plasma-500/30' : 'font-medium text-slate-700 hover:bg-slate-200/60'}">
                        <div class="flex items-center gap-3">
                            <svg id="icon-\${itemId}" class="w-4 h-4 \${item.active ? '' : (item.iconSpin ? 'text-plasma-500 animate-spin' : 'text-slate-500')}"><use href="#\${item.icon}"/></svg>
                            \${labelHtml}
                        </div>
                        \${item.badge && typeof item.badge === 'string' ? badgeHtml : ''}
                        \${item.hasSubmenu ? '<svg class="w-3.5 h-3.5 ' + (item.active ? 'text-white/70' : 'text-slate-400 group-hover:text-slate-600') + ' transition-colors"><use href="#icon-forward"/></svg>' : ''}
                    </a>\`;
            });
            
            el.innerHTML += html;
            
            items.forEach((item, idx) => {
                const itemId = containerId + '-' + idx;
                if (item.iconSpin) {
                    setTimeout(() => {
                        const icon = document.getElementById('icon-' + itemId);
                        if(icon) {
                            icon.classList.remove('animate-spin', 'text-plasma-500');
                            icon.classList.add('text-slate-500');
                        }
                        const complexBadge = document.getElementById('complex-badge-' + itemId);
                        const ping = document.getElementById('ping-' + itemId);
                        if (complexBadge && ping) {
                            complexBadge.outerHTML = '<span>' + item.label + '</span>';
                            ping.outerHTML = '<span class="px-2 py-0.5 text-[10px] font-semibold bg-slate-200 text-slate-700 rounded-full">4</span>';
                        }
                    }, 2000);
                }
            });
        };
`;

for (const filename of files) {
    const file = path.join(dir, filename);
    if (!fs.existsSync(file)) continue;
    let content = fs.readFileSync(file, 'utf-8');
    
    content = content.replace(oldRenderNavRegex, newRenderNav);
    
    fs.writeFileSync(file, content, 'utf-8');
    console.log('Updated animation logic in ' + file);
}
