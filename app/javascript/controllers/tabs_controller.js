// Initialize the tabs when the DOM is loaded
document.addEventListener('turbo:load', function () {
  initTabs();
});

// Also initialize when Turbo replaces the content
document.addEventListener('turbo:render', function () {
  initTabs();
});

function initTabs() {
  // Get all the tabs
  const tabs = document.querySelectorAll('[data-tabs-target]');
  if (!tabs.length) return;

  // Skip tabs that are managed by Stimulus controllers
  const nonStimulusTabs = Array.from(tabs).filter(tab => {
    // Check if the tab doesn't have a parent with a data-controller attribute
    return !tab.closest('[data-controller]');
  });

  if (!nonStimulusTabs.length) return;

  // Get all tab contents
  const tabContents = document.querySelectorAll('[id^="pending"], [id^="paid"], [id^="overdue"]');

  // Filter out tab contents that are managed by Stimulus
  const nonStimulusContents = Array.from(tabContents).filter(content => {
    return !content.closest('[data-controller]');
  });

  // Hide all tab contents initially
  nonStimulusContents.forEach(content => {
    content.classList.add('hidden');
  });

  // Show the first tab content and mark first tab as active
  if (nonStimulusContents.length > 0 && nonStimulusTabs.length > 0) {
    nonStimulusContents[0].classList.remove('hidden');
    nonStimulusTabs[0].classList.add('text-blue-600', 'border-blue-600');
  }

  // Add click events to tabs
  nonStimulusTabs.forEach(tab => {
    tab.addEventListener('click', function () {
      const target = document.querySelector(this.dataset.tabsTarget);

      // Hide all contents
      nonStimulusContents.forEach(content => {
        content.classList.add('hidden');
      });

      // Remove active class from all tabs
      nonStimulusTabs.forEach(t => {
        t.classList.remove('text-blue-600', 'border-blue-600');
        t.classList.add('hover:text-gray-600', 'hover:border-gray-300');
        t.setAttribute('aria-selected', 'false');
      });

      // Show selected content
      if (target) {
        target.classList.remove('hidden');
      }

      // Mark this tab as active
      this.classList.add('text-blue-600', 'border-blue-600');
      this.classList.remove('hover:text-gray-600', 'hover:border-gray-300');
      this.setAttribute('aria-selected', 'true');
    });
  });
}
