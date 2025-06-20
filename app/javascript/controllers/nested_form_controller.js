import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["target", "template", "addButton"]
  static values = { 
    wrapperSelector: { type: String, default: ".nested-form-wrapper" },
    association: String
  }

  connect() {
    this.initializeExistingForms()
  }

  initializeExistingForms() {
    this.findAllWrappers().forEach(wrapper => {
      this.setupRemoveButton(wrapper)
    })
  }

  add(e) {
    e.preventDefault()
    const button = e.target.closest('[data-action]')
    const targetSelector = button.dataset.nestedFormTargetParam || this.targetTarget.id
    const target = document.querySelector(`#${targetSelector}`) || this.targetTarget

    // Get the template for this specific level
    const template = button.closest('.nested-form-wrapper')?.querySelector('[data-nested-form-target="template"]') || 
                    this.templateTarget

    const content = this.replaceNewRecord(template.innerHTML)
    const wrapper = document.createElement('div')
    wrapper.innerHTML = content

    const newNestedForm = wrapper.querySelector(this.wrapperSelectorValue)
    if (!newNestedForm) return

    target.appendChild(newNestedForm)
    this.setupRemoveButton(newNestedForm)
    this.dispatch('added', { detail: { content: newNestedForm } })
  }

  remove(e) {
    e.preventDefault()
    const wrapper = e.target.closest(this.wrapperSelectorValue)
    if (!wrapper) return

    if (wrapper.dataset.newRecord === 'true') {
      wrapper.remove()
    } else {
      wrapper.querySelector("input[name*='_destroy']").value = '1'
      wrapper.style.display = 'none'
    }

    this.dispatch('removed', { detail: { content: wrapper } })
  }

  findAllWrappers() {
    return Array.from(this.element.querySelectorAll(this.wrapperSelectorValue))
  }

  setupRemoveButton(wrapper) {
    const removeButton = wrapper.querySelector('[data-action*="nested-form#remove"]')
    if (removeButton) {
      removeButton.addEventListener('click', this.remove.bind(this))
    }
  }

  replaceNewRecord(content) {
    const timestamp = new Date().getTime()
    return content.replace(/NEW_RECORD/g, timestamp)
  }
}