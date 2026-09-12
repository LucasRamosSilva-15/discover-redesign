const fs = require('fs');
const path = require('path');

const fileTeste = path.join('./Prototipo_web', 'teste.html');
const fileApp = path.join('./Prototipo_web', 'app-details.html');

let contentTeste = fs.readFileSync(fileTeste, 'utf-8');
let contentApp = fs.readFileSync(fileApp, 'utf-8');

// 1. Sync category icons
const iconRegex = /<!-- Category Icons -->([\s\S]*?)<\/svg>/;
const matchIcons = contentTeste.match(iconRegex);

if (matchIcons) {
    contentApp = contentApp.replace(iconRegex, `<!-- Category Icons -->${matchIcons[1]}</svg>`);
}

// 2. Sync renderNav array but keep 'Internet' active
const navRegex = /renderNav\('nav-group-categories', \[\s*([\s\S]*?)\s*\]\);/;
const matchNav = contentTeste.match(navRegex);

if (matchNav) {
    let newNavArray = matchNav[1];
    
    // We want to make 'Internet' active in app-details.html
    // Replace: { icon: 'cat-web', label: 'Internet' }
    // With: { icon: 'cat-web', label: 'Internet', active: true }
    newNavArray = newNavArray.replace(/{ icon: 'cat-web', label: 'Internet' }/, "{ icon: 'cat-web', label: 'Internet', active: true }");
    
    contentApp = contentApp.replace(navRegex, `renderNav('nav-group-categories', [\n${newNavArray}\n        ]);`);
}

fs.writeFileSync(fileApp, contentApp, 'utf-8');
console.log('Categories synced to app-details.html');

