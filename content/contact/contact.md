---
# An instance of the Contact widget.
# Documentation: https://sourcethemes.com/academic/docs/page-builder/
widget: contact

# Activate this widget? true/false
active: false

# Order that this section appears on the page.
weight: 10

# This file represents a page section.
headless: true

title: Contact
subtitle: "This form is for contacting me about speaking engagements, opportunities to work together, or mentorship requests."

content:
  # Automatically link email and phone or display as text?
  autolink: true

  # Email form provider
  form:
    provider: formspree
    formspree:
      id: test
    netlify:
      # Enable CAPTCHA challenge to reduce spam?
      captcha: true
  
design:
  columns: '1'
  spacing:
    padding: ["20px", "0", "20px", "0"]
---
