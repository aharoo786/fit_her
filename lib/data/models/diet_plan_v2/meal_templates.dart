// User-facing labels mirroring services/ai/constants/mealTemplates.js
// MEAL_TEMPLATES on the backend. Title Case for UI; the snake_case wire
// values live on MealTypeV2 and are sent over the wire by the model
// layer. Don't import these for API calls — they're for display only.

const Map<int, List<String>> mealTemplateLabels = {
  3: ['Breakfast', 'Lunch', 'Dinner'],
  4: ['Breakfast', 'Lunch', 'Snack', 'Dinner'],
  5: ['Breakfast', 'Mid-morning', 'Lunch', 'Snack', 'Dinner'],
  6: [
    'Breakfast',
    'Mid-morning',
    'Lunch',
    'Snack',
    'Evening Snack',
    'Dinner',
  ],
};

const List<int> validMealsPerDay = [3, 4, 5, 6];

String mealTemplateHint(int mealsPerDay) {
  final labels = mealTemplateLabels[mealsPerDay];
  return labels == null ? '' : labels.join(', ');
}
