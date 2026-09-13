const fs = require('fs');
const path = require('path');

const dir = './Prototipo_web';
const files = ['teste.html', 'app-details.html', 'settings.html', 'updates.html', 'installed.html', 'about.html', 'category.html'];

const oldCategoriesRegex = /renderNav\('nav-group-categories', \[\s*([\s\S]*?)\s*\]\);/g;

const newCategories = `renderNav('nav-group-categories', [
            { id: 'todos', icon: 'cat-todos', label: 'Todos os aplicativos', href: 'category.html?id=todos' },
            { id: 'acess', icon: 'cat-acess', label: 'Acessibilidade', href: 'category.html?id=acess' },
            { id: 'ciencia', icon: 'cat-ciencia', label: 'Ciências e matemática', hasSubmenu: true, href: 'category.html?id=ciencia' },
            { id: 'dev', icon: 'cat-dev', label: 'Desenvolvimento', hasSubmenu: true, href: 'category.html?id=dev' },
            { id: 'edu', icon: 'cat-edu', label: 'Educação', href: 'category.html?id=edu' },
            { id: 'office', icon: 'cat-office', label: 'Escritório', href: 'category.html?id=office' },
            { id: 'gfx', icon: 'cat-gfx', label: 'Gráficos', hasSubmenu: true, href: 'category.html?id=gfx' },
            { id: 'web', icon: 'cat-web', label: 'Internet', href: 'category.html?id=web' },
            { id: 'games', icon: 'cat-games', label: 'Jogos', href: 'category.html?id=games' },
            { id: 'media', icon: 'cat-media', label: 'Multimídia', hasSubmenu: true, href: 'category.html?id=media' },
            { id: 'sys', icon: 'cat-sys', label: 'Sistema', href: 'category.html?id=sys' },
            { id: 'utils', icon: 'cat-utils', label: 'Utilitários', href: 'category.html?id=utils' },
            { id: 'drv', icon: 'cat-drv', label: 'Drivers de hardware', href: 'category.html?id=drv' }
        ]);`;

for (const filename of files) {
    const file = path.join(dir, filename);
    if (!fs.existsSync(file)) continue;
    let content = fs.readFileSync(file, 'utf-8');
    
    // Check if there is an active attribute somewhere we need to preserve...
    // Actually, setting active manually via URL param in JS is much smarter.
    
    // We will update the renderNav function itself to automatically set active based on URL if it's category.html
    // Let's replace the categories array
    content = content.replace(oldCategoriesRegex, newCategories);
    
    fs.writeFileSync(file, content, 'utf-8');
    console.log('Updated categories links in ' + file);
}
