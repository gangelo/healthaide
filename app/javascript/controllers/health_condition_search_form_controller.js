import SearchFormController from "controllers/search_form_controller";

/**
 * HealthConditionSearchFormController specializes the SearchFormController for health condition searches
 */
export default class HealthConditionSearchFormController extends SearchFormController {
  static targets = [...SearchFormController.targets, "container"]
  
  static values = {
    ...SearchFormController.values,
    listFrameId: { type: String, default: "health_conditions_list" },
    resourceType: { type: String, default: "health_condition" },
    searchPath: { type: String, default: "/user_health_conditions/select_multiple" }
  }
  
  connect() {
    super.connect();
    this.searchTimeout = null;
  }
}
