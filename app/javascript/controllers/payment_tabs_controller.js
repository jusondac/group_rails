import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="payment-tabs"
export default class extends Controller {
  static targets = ["tab", "content"]

  connect() {
    console.log("Payment tabs controller connected")

    // Debug output to help diagnose issues
    if (this.tabTargets.length === 0) {
      console.error("No tab targets found! Check your HTML for data-payment-tabs-target='tab' attributes")
    }

    if (this.contentTargets.length === 0) {
      console.error("No content targets found! Check your HTML for data-payment-tabs-target='content' attributes")
    }

    console.log(`Found ${this.tabTargets.length} tabs and ${this.contentTargets.length} content panels`)

    // Print each tab ID to verify they're registered correctly
    this.tabTargets.forEach((tab, i) => {
      console.log(`Tab ${i} id: ${tab.id}`)
    })

    // Print each content ID to verify they're registered correctly
    this.contentTargets.forEach((content, i) => {
      console.log(`Content ${i} id: ${content.id}`)
    })

    // Add a small delay to ensure DOM is fully loaded
    setTimeout(() => {
      // Default to showing the first tab
      if (this.tabTargets.length > 0) {
        this.showTab(0)
        console.log("First tab activated by default")
      }
    }, 50)
  }

  showTab(index) {
    // Hide all content
    this.contentTargets.forEach((content, i) => {
      content.classList.add('hidden')
      console.log(`Tab content ${i}: ${content.id} hidden`)
    })

    // Remove active state from all tabs
    this.tabTargets.forEach((tab, i) => {
      tab.classList.remove('text-blue-600', 'border-blue-600')
      tab.classList.add('hover:text-gray-600', 'hover:border-gray-300', 'border-transparent')
      tab.setAttribute('aria-selected', 'false')
      console.log(`Tab ${i}: ${tab.id} deactivated`)
    })

    // Show selected content and activate tab
    if (this.contentTargets[index]) {
      this.contentTargets[index].classList.remove('hidden')
      console.log(`Tab content ${index}: ${this.contentTargets[index].id} shown`)
    }

    if (this.tabTargets[index]) {
      this.tabTargets[index].classList.add('text-blue-600', 'border-blue-600')
      this.tabTargets[index].classList.remove('hover:text-gray-600', 'hover:border-gray-300', 'border-transparent')
      this.tabTargets[index].setAttribute('aria-selected', 'true')
      console.log(`Tab ${index}: ${this.tabTargets[index].id} activated`)
    }
  }

  select(event) {
    const index = this.tabTargets.indexOf(event.currentTarget)
    console.log(`Tab selected: ${event.currentTarget.id} at index ${index}`)
    this.showTab(index)
  }
}
