/**
 * Smart Campus Event & Workshop Portal - Client Interactions
 */

document.addEventListener('DOMContentLoaded', () => {
    // 1. Carousel Initialization (if exists)
    initHeroCarousel();

    // 2. Flash Alert Auto-dismiss
    initFlashAlerts();

    // 3. Category Filter
    initCategoryFilter();

    // 4. Modal Triggers
    initModalHandlers();
});

/**
 * Hero Banner Carousel
 */
function initHeroCarousel() {
    const slides = document.querySelectorAll('.carousel-slide');
    if (!slides.length) return;

    let currentIndex = 0;
    const totalSlides = slides.length;
    const intervalTime = 5000;

    const showSlide = (index) => {
        slides.forEach((slide, i) => {
            slide.classList.toggle('active', i === index);
            slide.classList.toggle('opacity-100', i === index);
            slide.classList.toggle('opacity-0', i !== index);
        });

        // Update dots if present
        const dots = document.querySelectorAll('.carousel-dot');
        dots.forEach((dot, i) => {
            if (i === index) {
                dot.classList.add('bg-white', 'w-8');
                dot.classList.remove('bg-white/50', 'w-3');
            } else {
                dot.classList.remove('bg-white', 'w-8');
                dot.classList.add('bg-white/50', 'w-3');
            }
        });
    };

    const nextSlide = () => {
        currentIndex = (currentIndex + 1) % totalSlides;
        showSlide(currentIndex);
    };

    let timer = setInterval(nextSlide, intervalTime);

    // Pause on hover
    const carouselContainer = document.getElementById('heroCarousel');
    if (carouselContainer) {
        carouselContainer.addEventListener('mouseenter', () => clearInterval(timer));
        carouselContainer.addEventListener('mouseleave', () => timer = setInterval(nextSlide, intervalTime));
    }

    // Dot click listeners
    const dots = document.querySelectorAll('.carousel-dot');
    dots.forEach((dot, idx) => {
        dot.addEventListener('click', () => {
            currentIndex = idx;
            showSlide(currentIndex);
        });
    });

    const prevBtn = document.getElementById('carouselPrev');
    const nextBtn = document.getElementById('carouselNext');
    if (prevBtn) {
        prevBtn.addEventListener('click', () => {
            currentIndex = (currentIndex - 1 + totalSlides) % totalSlides;
            showSlide(currentIndex);
        });
    }
    if (nextBtn) {
        nextBtn.addEventListener('click', () => {
            nextSlide();
        });
    }
}

/**
 * Flash alerts dismiss button
 */
function initFlashAlerts() {
    const alerts = document.querySelectorAll('.flash-alert');
    alerts.forEach(alert => {
        const closeBtn = alert.querySelector('.alert-close');
        if (closeBtn) {
            closeBtn.addEventListener('click', () => {
                alert.classList.add('opacity-0', 'transition-opacity', 'duration-300');
                setTimeout(() => alert.remove(), 300);
            });
        }

        // Auto dismiss after 6 seconds
        setTimeout(() => {
            if (document.body.contains(alert)) {
                alert.classList.add('opacity-0', 'transition-opacity', 'duration-500');
                setTimeout(() => alert.remove(), 500);
            }
        }, 6000);
    });
}

/**
 * Dynamic Filter on Workshops/Events listing
 */
function initCategoryFilter() {
    const filterSelect = document.getElementById('categoryFilter');
    const searchInput = document.getElementById('listingSearch');
    const eventCards = document.querySelectorAll('.event-card-item');

    if (!filterSelect && !searchInput) return;

    function applyFilter() {
        const selectedCat = filterSelect ? filterSelect.value.toLowerCase() : 'all';
        const searchKeyword = searchInput ? searchInput.value.toLowerCase().trim() : '';

        let visibleCount = 0;

        eventCards.forEach(card => {
            const cardCat = (card.getAttribute('data-category') || '').toLowerCase();
            const cardTitle = (card.getAttribute('data-title') || '').toLowerCase();
            const cardVenue = (card.getAttribute('data-venue') || '').toLowerCase();

            const matchesCategory = (selectedCat === 'all' || selectedCat === '' || cardCat === selectedCat);
            const matchesSearch = (searchKeyword === '' || cardTitle.includes(searchKeyword) || cardVenue.includes(searchKeyword));

            if (matchesCategory && matchesSearch) {
                card.style.display = 'flex';
                visibleCount++;
            } else {
                card.style.display = 'none';
            }
        });

        const emptyNotice = document.getElementById('noResultsNotice');
        if (emptyNotice) {
            emptyNotice.style.display = (visibleCount === 0) ? 'block' : 'none';
        }
    }

    if (filterSelect) filterSelect.addEventListener('change', applyFilter);
    if (searchInput) searchInput.addEventListener('input', applyFilter);
}

/**
 * Generic Modal Handler
 */
function initModalHandlers() {
    // Open modal buttons
    document.querySelectorAll('[data-modal-target]').forEach(trigger => {
        trigger.addEventListener('click', (e) => {
            e.preventDefault();
            const targetId = trigger.getAttribute('data-modal-target');
            const modal = document.getElementById(targetId);
            if (modal) {
                openModal(modal);
            }
        });
    });

    // Close buttons inside modals
    document.querySelectorAll('[data-modal-close]').forEach(button => {
        button.addEventListener('click', () => {
            const modal = button.closest('.app-modal');
            if (modal) {
                closeModal(modal);
            }
        });
    });

    // Close on clicking backdrop
    document.querySelectorAll('.app-modal').forEach(modal => {
        modal.addEventListener('click', (e) => {
            if (e.target === modal) {
                closeModal(modal);
            }
        });
    });
}

function openModal(modal) {
    modal.classList.remove('hidden');
    modal.classList.add('flex');
    document.body.classList.add('overflow-hidden');
}

function closeModal(modal) {
    modal.classList.add('hidden');
    modal.classList.remove('flex');
    document.body.classList.remove('overflow-hidden');
}

/**
 * Helper to download calendar ICS file
 */
function downloadIcsCalendar(title, description, venue, startIso, endIso) {
    const formatDate = (isoStr) => {
        const d = new Date(isoStr);
        return d.toISOString().replace(/[-:]/g, '').split('.')[0] + 'Z';
    };

    const icsData = [
        'BEGIN:VCALENDAR',
        'VERSION:2.0',
        'PRODID:-//Smart Campus Event Portal//EN',
        'BEGIN:VEVENT',
        `SUMMARY:${title}`,
        `DESCRIPTION:${description.replace(/\n/g, '\\n')}`,
        `LOCATION:${venue}`,
        `DTSTART:${formatDate(startIso)}`,
        `DTEND:${formatDate(endIso)}`,
        'STATUS:CONFIRMED',
        'END:VEVENT',
        'END:VCALENDAR'
    ].join('\r\n');

    const blob = new Blob([icsData], { type: 'text/calendar;charset=utf-8' });
    const link = document.createElement('a');
    link.href = window.URL.createObjectURL(blob);
    link.setAttribute('download', `${title.replace(/[^a-z0-9]/gi, '_').toLowerCase()}.ics`);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
}
