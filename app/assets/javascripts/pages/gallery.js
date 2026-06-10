// Gallery page JavaScript
document.addEventListener('DOMContentLoaded', () => {
  const uploadBtn = document.getElementById('uploadBtn');
  const uploadModal = document.getElementById('uploadModal');
  const closeModal = document.getElementById('closeModal');
  const dateFilter = document.querySelector('.date-filter');

  if (uploadBtn) {
    uploadBtn.addEventListener('click', () => {
      uploadModal.style.display = 'block';
    });
  }

  if (closeModal) {
    closeModal.addEventListener('click', () => {
      uploadModal.style.display = 'none';
    });
  }

  if (uploadModal) {
    window.addEventListener('click', (e) => {
      if (e.target === uploadModal) {
        uploadModal.style.display = 'none';
      }
    });
  }

  if (dateFilter) {
    dateFilter.addEventListener('change', (e) => {
      const form = e.target.closest('form');
      if (form) form.submit();
    });
  }
});
