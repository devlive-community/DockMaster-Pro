document.addEventListener('DOMContentLoaded', () => {
    // Scroll-aware nav
    const nav = document.getElementById('nav');
    if (nav) {
        window.addEventListener('scroll', () => {
            nav.classList.toggle('scrolled', window.scrollY > 20);
        });
    }

    // Fade-in on scroll
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('visible');
            }
        });
    }, { threshold: 0.1 });

    document.querySelectorAll('.fade-in').forEach(el => observer.observe(el));

    // Docs: active sidebar link on scroll
    const docLinks = document.querySelectorAll('.docs-nav a');
    if (docLinks.length > 0) {
        const sections = [];
        docLinks.forEach(link => {
            const id = link.getAttribute('href').replace('#', '');
            const section = document.getElementById(id);
            if (section) sections.push({ id, el: section, link });
        });

        window.addEventListener('scroll', () => {
            let current = sections[0];
            for (const s of sections) {
                if (s.el.getBoundingClientRect().top <= 120) {
                    current = s;
                }
            }
            docLinks.forEach(l => l.classList.remove('active'));
            if (current) current.link.classList.add('active');
        });

        // Smooth scroll for doc links
        docLinks.forEach(link => {
            link.addEventListener('click', (e) => {
                e.preventDefault();
                const id = link.getAttribute('href').replace('#', '');
                const target = document.getElementById(id);
                if (target) {
                    target.scrollIntoView({ behavior: 'smooth', block: 'start' });
                }
            });
        });
    }
});
