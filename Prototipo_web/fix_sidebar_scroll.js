const fs = require('fs');
const path = require('path');

const dir = './Prototipo_web';
const files = ['teste.html', 'app-details.html', 'settings.html', 'updates.html', 'installed.html', 'about.html', 'category.html'];

for (const filename of files) {
    const file = path.join(dir, filename);
    if (!fs.existsSync(file)) continue;
    let content = fs.readFileSync(file, 'utf-8');
    
    // Step 1: Remove overflow-y-auto from aside and add h-full (though flex-1 from parent might already constrain it)
    content = content.replace(
        /<aside class="([^"]*)overflow-y-auto([^"]*)">/,
        '<aside class="$1h-full$2">'
    );
    
    // Step 2: Add flex-1 overflow-y-auto to the div wrapping the nav groups
    content = content.replace(
        /<div class="p-3 space-y-6">/,
        '<div class="p-3 space-y-6 flex-1 overflow-y-auto">'
    );
    
    // Step 3: Ensure the footer has shrink-0 (it already is outside the scrolling div, but let's be safe)
    // <div class="p-3 border-t border-slate-200/80 bg-slate-100/50 flex items-center justify-between text-[11px] text-slate-500">
    content = content.replace(
        /<div class="p-3 border-t border-slate-200\/80 bg-slate-100\/50 flex items-center justify-between text-\[11px\] text-slate-500">/,
        '<div class="p-3 border-t border-slate-200/80 bg-slate-100/50 flex items-center justify-between text-[11px] text-slate-500 shrink-0">'
    );

    fs.writeFileSync(file, content, 'utf-8');
    console.log('Fixed sidebar scroll in ' + file);
}
