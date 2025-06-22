import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["provider", "model", "apiKey"];
  static values = {
    models: Object,
    currentProvider: String,
    currentModel: String,
    currentApiKey: String,
  };

  connect() {
    this.updateFields();
  }

  providerChanged() {
    this.updateFields();
  }

  updateFields() {
    const selectedProvider = this.providerTarget.value;
    const isNoProvider = selectedProvider === "no_provider";

    // Update model select options
    this.updateModelOptions(selectedProvider);

    // Enable/disable model and API key fields
    this.modelTarget.disabled = isNoProvider;
    this.apiKeyTarget.disabled = isNoProvider;

    // Update visual styling
    if (isNoProvider) {
      this.modelTarget.value = "";
      this.apiKeyTarget.value = "";
      this.modelTarget.classList.add("bg-gray-100", "cursor-not-allowed");
      this.apiKeyTarget.classList.add("bg-gray-100", "cursor-not-allowed");
    } else {
      this.modelTarget.classList.remove("bg-gray-100", "cursor-not-allowed");
      this.apiKeyTarget.classList.remove("bg-gray-100", "cursor-not-allowed");
    }

    this.updateModel(selectedProvider);
    this.updateApiKey(selectedProvider);
  }

  updateModelOptions(provider) {
    const provider_models = this.modelsValue[provider] || {};
    const models = Object.keys(provider_models[0]);
    const modelSelect = this.modelTarget;

    // Clear existing options except prompt
    while (modelSelect.children.length > 1) {
      modelSelect.removeChild(modelSelect.lastChild);
    }

    // Add new options
    Object.entries(models).forEach(([_index, model]) => {
      const option = document.createElement("option");
      option.value = model;
      option.textContent = model;
      modelSelect.appendChild(option);
    });

    // Reset selection
    modelSelect.value = "";
  }

  updateModel(provider) {
    if (provider === this.currentProviderValue)
      this.modelTarget.value = this.currentModelValue;
    else this.modelTarget.value = "";
  }

  updateApiKey(provider) {
    if (provider === this.currentProviderValue)
      this.apiKeyTarget.value = this.currentApiKeyValue;
    else this.apiKeyTarget.value = "";
  }
}
