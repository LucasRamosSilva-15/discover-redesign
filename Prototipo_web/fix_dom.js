const fs = require('fs');
const path = require('path');

const dir = './Prototipo_web';
const files = ['teste.html', 'app-details.html', 'settings.html', 'updates.html', 'installed.html', 'about.html', 'category.html'];

for (const filename of files) {
    const file = path.join(dir, filename);
    if (!fs.existsSync(file)) continue;
    let content = fs.readFileSync(file, 'utf-8');
    
    // Fix 1: The opening tag that was changed from <div to <a
    content = content.replace(/<a href="app-details\.html" class="block group bg-white rounded-xl p-4/g, '<div class="group bg-white rounded-xl p-4');
    
    // Some tags might have been changed by the second regex if the first failed (unlikely, but just in case)
    content = content.replace(/<a href="app-details\.html" style="text-decoration: none; color: inherit;" class="group bg-white rounded-xl p-4/g, '<div class="group bg-white rounded-xl p-4');

    // Fix 2: The closing tag in renderApps that was changed from </div> to </a>
    content = content.replace(/(\$\{btnHtml\})\s*<\/a>/g, '$1\n                    </div>');
    content = content.replace(/(\$\{installButton\})\s*<\/a>/g, '$1\n                    </div>');

    // Also remove the </a> that might have been left over if they were statically changed
    // Wait, if it was static, I didn't change the closing tag, so it's still </div>.
    
    // Just to be safe, I'll write the content back
    fs.writeFileSync(file, content, 'utf-8');
    console.log('Fixed DOM in ' + file);
}
