/**
 * Main JavaScript for IBM Maximo Application Framework Local Configuration
 * Handles interactive features, navigation, and copy-to-clipboard
 */

(function() {
  'use strict';

  // ============================================
  // Mobile Menu Toggle
  // ============================================
  function initMobileMenu() {
    const menuToggle = document.querySelector('.menu-toggle');
    const nav = document.querySelector('.nav');
    
    if (menuToggle && nav) {
      menuToggle.addEventListener('click', function() {
        const isOpen = nav.classList.contains('translate-x-0');
        
        if (isOpen) {
          // Close menu
          nav.classList.remove('translate-x-0');
          nav.classList.add('translate-x-full');
          menuToggle.setAttribute('aria-expanded', 'false');
          menuToggle.innerHTML = '☰';
        } else {
          // Open menu
          nav.classList.remove('translate-x-full');
          nav.classList.add('translate-x-0');
          menuToggle.setAttribute('aria-expanded', 'true');
          menuToggle.innerHTML = '✕';
        }
      });
      
      // Close menu when clicking outside
      document.addEventListener('click', function(e) {
        if (!nav.contains(e.target) && !menuToggle.contains(e.target)) {
          nav.classList.remove('translate-x-0');
          nav.classList.add('translate-x-full');
          menuToggle.setAttribute('aria-expanded', 'false');
          menuToggle.innerHTML = '☰';
        }
      });
      
      // Close menu when clicking a nav link
      const navLinks = nav.querySelectorAll('.nav-link');
      navLinks.forEach(link => {
        link.addEventListener('click', function() {
          nav.classList.remove('translate-x-0');
          nav.classList.add('translate-x-full');
          menuToggle.setAttribute('aria-expanded', 'false');
          menuToggle.innerHTML = '☰';
        });
      });
    }
  }

  // ============================================
  // Toast Notification
  // ============================================
  function showToast(message, type = 'success') {
    // Remove any existing toasts
    const existingToast = document.querySelector('.toast-notification');
    if (existingToast) {
      existingToast.remove();
    }

    // Create toast element
    const toast = document.createElement('div');
    toast.className = 'toast-notification fixed bottom-8 right-8 px-6 py-4 rounded-lg shadow-2xl transform translate-y-0 transition-all duration-300 ease-out z-50 flex items-center gap-3';
    
    if (type === 'success') {
      toast.classList.add('bg-emerald-500', 'text-white');
      toast.innerHTML = `
        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
        </svg>
        <span class="font-medium">${message}</span>
      `;
    } else {
      toast.classList.add('bg-red-500', 'text-white');
      toast.innerHTML = `
        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
        </svg>
        <span class="font-medium">${message}</span>
      `;
    }

    // Add to document
    document.body.appendChild(toast);

    // Animate in
    setTimeout(() => {
      toast.style.transform = 'translateY(0)';
    }, 10);

    // Remove after 2 seconds
    setTimeout(() => {
      toast.style.transform = 'translateY(100px)';
      toast.style.opacity = '0';
      setTimeout(() => {
        toast.remove();
      }, 300);
    }, 2000);
  }

  // ============================================
  // Copy to Clipboard
  // ============================================
  function initCopyButtons() {
    // Select both .copy-button and .code-block-copy classes
    const copyButtons = document.querySelectorAll('.copy-button, .code-block-copy');
    
    copyButtons.forEach(button => {
      button.addEventListener('click', async function() {
        // Find the code element - could be in a sibling div or parent structure
        let code = null;
        
        // Try to find code in parent structure
        const parent = this.closest('.code-block') || this.parentElement.parentElement;
        if (parent) {
          code = parent.querySelector('code');
        }
        
        // If still not found, try next sibling
        if (!code) {
          const nextDiv = this.parentElement.nextElementSibling;
          if (nextDiv) {
            code = nextDiv.querySelector('code');
          }
        }
        
        if (code) {
          try {
            await navigator.clipboard.writeText(code.textContent.trim());
            
            // Show toast notification
            showToast('Copied to clipboard!');
            
            // Visual feedback on button
            const originalHTML = this.innerHTML;
            this.innerHTML = '<span class="text-emerald-400">✓ Copied!</span>';
            
            setTimeout(() => {
              this.innerHTML = originalHTML;
            }, 2000);
          } catch (err) {
            console.error('Failed to copy:', err);
            
            // Show error toast
            showToast('Failed to copy', 'error');
            
            const originalHTML = this.innerHTML;
            this.innerHTML = '<span class="text-red-400">✗ Failed</span>';
            
            setTimeout(() => {
              this.innerHTML = originalHTML;
            }, 2000);
          }
        } else {
          console.error('Could not find code element to copy');
          showToast('Failed to copy', 'error');
        }
      });
    });
  }

  // ============================================
  // Smooth Scroll for Anchor Links
  // ============================================
  function initSmoothScroll() {
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
      anchor.addEventListener('click', function(e) {
        const href = this.getAttribute('href');
        
        // Skip if it's just "#"
        if (href === '#') return;
        
        const target = document.querySelector(href);
        if (target) {
          e.preventDefault();
          const headerOffset = 80;
          const elementPosition = target.getBoundingClientRect().top;
          const offsetPosition = elementPosition + window.pageYOffset - headerOffset;
          
          window.scrollTo({
            top: offsetPosition,
            behavior: 'smooth'
          });
        }
      });
    });
  }

  // ============================================
  // Active Navigation Link
  // ============================================
  function initActiveNav() {
    const navLinks = document.querySelectorAll('.nav-link');
    const currentPath = window.location.pathname;
    
    navLinks.forEach(link => {
      const linkPath = new URL(link.href).pathname;
      if (linkPath === currentPath || 
          (currentPath === '/' && linkPath.endsWith('index.html')) ||
          (currentPath.endsWith('/') && linkPath.endsWith('index.html'))) {
        link.classList.add('active');
      }
    });
  }

  // ============================================
  // Scroll Header Hide/Show
  // ============================================
  function initScrollHeader() {
    const header = document.querySelector('header');
    if (!header) return;
    
    let lastScroll = 0;
    const scrollThreshold = 100;
    
    window.addEventListener('scroll', function() {
      const currentScroll = window.pageYOffset;
      
      if (currentScroll <= scrollThreshold) {
        header.classList.remove('-translate-y-full');
      } else if (currentScroll > lastScroll && currentScroll > scrollThreshold) {
        // Scrolling down
        header.classList.add('-translate-y-full');
      } else {
        // Scrolling up
        header.classList.remove('-translate-y-full');
      }
      
      lastScroll = currentScroll;
    });
  }

  // ============================================
  // Fade In on Scroll
  // ============================================
  function initScrollAnimations() {
    const observerOptions = {
      threshold: 0.1,
      rootMargin: '0px 0px -50px 0px'
    };
    
    const observer = new IntersectionObserver(function(entries) {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          entry.target.classList.add('opacity-100', 'translate-y-0');
          entry.target.classList.remove('opacity-0', 'translate-y-4');
          observer.unobserve(entry.target);
        }
      });
    }, observerOptions);
    
    // Observe cards and sections with initial hidden state
    document.querySelectorAll('.card, .step, .feature-card, .step-card').forEach(el => {
      el.classList.add('opacity-0', 'translate-y-4', 'transition-all', 'duration-700');
      observer.observe(el);
    });
  }

  // ============================================
  // Add Copy Buttons to Code Blocks (if needed)
  // ============================================
  function addCopyButtonsToCodeBlocks() {
    const codeBlocks = document.querySelectorAll('pre:not(.code-block pre)');
    
    codeBlocks.forEach(pre => {
      // Skip if already wrapped
      if (pre.closest('.code-block')) return;
      
      // Create wrapper
      const wrapper = document.createElement('div');
      wrapper.className = 'code-block bg-slate-800 rounded-xl border border-slate-700 overflow-hidden';
      
      // Create header
      const header = document.createElement('div');
      header.className = 'flex items-center justify-between px-6 py-4 bg-slate-900/50 border-b border-slate-700';
      
      const title = document.createElement('span');
      title.className = 'text-sm font-mono text-slate-400';
      title.textContent = 'Code';
      
      const copyBtn = document.createElement('button');
      copyBtn.className = 'copy-button px-4 py-2 text-sm bg-slate-700 hover:bg-slate-600 text-slate-300 rounded-lg transition-colors';
      copyBtn.innerHTML = '<span class="copy-icon">📋</span> <span class="copy-text">Copy</span>';
      copyBtn.setAttribute('aria-label', 'Copy code to clipboard');
      
      header.appendChild(title);
      header.appendChild(copyBtn);
      
      // Create content wrapper
      const content = document.createElement('div');
      content.className = 'p-6';
      
      // Wrap the pre element
      pre.parentNode.insertBefore(wrapper, pre);
      wrapper.appendChild(header);
      wrapper.appendChild(content);
      content.appendChild(pre);
    });
  }

  // ============================================
  // External Links
  // ============================================
  function initExternalLinks() {
    const links = document.querySelectorAll('a[href^="http"]');
    
    links.forEach(link => {
      // Skip if it's an internal link
      if (link.hostname === window.location.hostname) return;
      
      link.setAttribute('target', '_blank');
      link.setAttribute('rel', 'noopener noreferrer');
      
      // Add visual indicator if not already present
      if (!link.querySelector('.external-icon') && !link.textContent.includes('↗')) {
        const icon = document.createElement('span');
        icon.className = 'external-icon';
        icon.innerHTML = ' ↗';
        icon.setAttribute('aria-hidden', 'true');
        link.appendChild(icon);
      }
    });
  }

  // ============================================
  // Initialize All Features
  // ============================================
  function init() {
    // Wait for DOM to be ready
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', init);
      return;
    }
    
    initMobileMenu();
    initActiveNav();
    initSmoothScroll();
    initScrollHeader();
    addCopyButtonsToCodeBlocks();
    initCopyButtons();
    initScrollAnimations();
    initExternalLinks();
    
    console.log('IBM Maximo Application Framework Local Configuration site initialized with Tailwind CSS');
  }

  // Start initialization
  init();

  // ============================================
  // Expose utility functions globally
  // ============================================
  window.MaximoDevTools = {
    copyToClipboard: async function(text) {
      try {
        await navigator.clipboard.writeText(text);
        return true;
      } catch (err) {
        console.error('Failed to copy:', err);
        return false;
      }
    }
  };

})();

// Made with Bob
