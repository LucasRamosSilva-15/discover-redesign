const fs = require('fs');
const path = require('path');

const dir = './Prototipo_web';
const files = ['teste.html', 'app-details.html', 'settings.html', 'updates.html', 'installed.html', 'about.html', 'category.html'];

for (const filename of files) {
    const file = path.join(dir, filename);
    if (!fs.existsSync(file)) continue;
    let content = fs.readFileSync(file, 'utf-8');
    
    // The current line looks like:
    // { icon: 'nav-atualizacoes', label: 'Atualizações', badge: { text: 'buscando...', href: 'updates.html' }, iconSpin: true },
    // OR
    // { icon: 'nav-atualizacoes', label: 'Atualizações', badge: '4', href: 'updates.html' }, (if it was somehow fixed)
    
    // We want to make sure it has href: 'updates.html' at the object root.
    // Let's just find the entire line and rewrite it properly.
    // In teste.html it might be: { icon: 'nav-atualizacoes', label: 'Atualizações', badge: { text: 'buscando...', href: 'updates.html' }, iconSpin: true }
    
    content = content.replace(/{ icon: 'nav-atualizacoes', label: 'Atualizações', badge: \{ text: 'buscando\.\.\.', href: 'updates\.html' \}, iconSpin: true }/g, 
        "{ icon: 'nav-atualizacoes', label: 'Atualizações', badge: { text: 'buscando...' }, iconSpin: true, href: 'updates.html' }");
        
    // Also check for the active version if we are in updates.html
    // In updates.html it might be: { icon: 'nav-atualizacoes', label: 'Atualizações', badge: '4', active: true, href: 'updates.html' }
    // It's probably fine there, but let's be careful.
    
    // Let's do a more robust replace:
    // If it has badge: { text: 'buscando...', href: 'updates.html' }
    content = content.replace(/badge: \{ text: 'buscando\.\.\.', href: 'updates\.html' \}/g, "badge: { text: 'buscando...' }");
    // And if the line doesn't have href: 'updates.html' at the end, we add it.
    // Actually, since we just removed it from the badge, the line now ends with iconSpin: true }
    content = content.replace(/{ icon: 'nav-atualizacoes', label: 'Atualizações', badge: \{ text: 'buscando\.\.\.' \}, iconSpin: true }/g, 
        "{ icon: 'nav-atualizacoes', label: 'Atualizações', badge: { text: 'buscando...' }, iconSpin: true, href: 'updates.html' }");
    
    fs.writeFileSync(file, content, 'utf-8');
    console.log('Fixed link in ' + file);
}
