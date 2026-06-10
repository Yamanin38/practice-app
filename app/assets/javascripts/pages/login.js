// Login page JavaScript
document.addEventListener('DOMContentLoaded', () => {
  const loginForm = document.querySelector('.login-form');

  if (loginForm) {
    loginForm.addEventListener('submit', (e) => {
      // Form submission handled by Rails form_with
      // JavaScript here for any additional validation or UX enhancements
    });
  }
});
