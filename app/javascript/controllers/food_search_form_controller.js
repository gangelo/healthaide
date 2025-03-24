import SearchFormController from "controllers/search_form_controller";

/**
 * FoodSearchFormController specializes the SearchFormController for food searches
 */
export default class FoodSearchFormController extends SearchFormController {
    static values = {
      ...SearchFormController.values,
      frame: { type: String, default: "foods_list" },
      url: { type: String, default: "/user_foods/select_multiple?frame_id=foods_list" }
    }
  }
