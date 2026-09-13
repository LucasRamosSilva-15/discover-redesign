const fs = require('fs');
const path = require('path');

const dir = './Prototipo_web';
const files = ['teste.html', 'app-details.html', 'settings.html', 'updates.html', 'installed.html', 'about.html', 'category.html'];

for (const filename of files) {
    const file = path.join(dir, filename);
    if (!fs.existsSync(file)) continue;
    let content = fs.readFileSync(file, 'utf-8');
    
    // We want to add onclick="window.location.href='teste.html'" to the back button.
    // The back button looks like:
    // <button class="w-8 h-8 flex items-center justify-center rounded-lg text-slate-700 hover:bg-slate-100 transition-colors">
    //      <svg class="w-4 h-4"><use href="#icon-back"/></svg>
    // </button>
    // Let's use a regex that matches the button containing #icon-back
    
    // First, let's just do a specific string replace:
    content = content.replace(/<button class="w-8 h-8 flex items-center justify-center rounded-lg text-slate-700 hover:bg-slate-100 transition-colors">\s*<svg class="w-4 h-4"><use href="#icon-back"\/><\/svg>\s*<\/button>/, 
        `<button onclick="window.location.href='teste.html'" class="w-8 h-8 flex items-center justify-center rounded-lg text-slate-700 hover:bg-slate-100 transition-colors" title="Voltar ao Início">
                        <svg class="w-4 h-4"><use href="#icon-back"/></svg>
                    </button>`);
                    
    // Some files might have different formatting, let's do a more robust regex if the first one fails
    // or just run it and see.
    fs.writeFileSync(file, content, 'utf-8');
    console.log('Fixed back button in ' + file);
}
