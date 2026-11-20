/**
 * Smart Campus Event & Workshop Portal
 * Client-Side JavaScript Validation & Student Account Patterns
 * Academic Web Technology Submission
 */

// ============================================================================
// 1. REGEX LOGIC PATTERNS FOR STUDENT ACCOUNT ATTRIBUTES
// ============================================================================
const STUDENT_VALIDATION_PATTERNS = {
    // Student ID: [Dept Code 2-4 letters] - [4-digit Batch Year] - [4-5 digit Roll No]
    // Valid Examples: CS-2024-8842, DS-2023-1092, SE-2025-5510, IT-2026-0042
    studentId: /^[A-Z]{2,4}-\d{4}-\d{4,5}$/i,

    // Full Name: Alphabet characters, dots, apostrophes, and spaces only (3 to 50 chars)
    fullName: /^[a-zA-Z\s.']{3,50}$/,

    // Official University Email: Must end with university campus domain
    // Examples: alex.c@smartcampus.edu, student@smartcampus.edu
    campusEmail: /^[a-zA-Z0-9._%+-]+@([a-zA-Z0-9.-]+\.)?smartcampus\.edu$/i,

    // General Standard Email (RFC 5322 compatible fallback)
    generalEmail: /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/,

    // Contact Phone: Optional international prefix (+), spaces, brackets, 10 to 15 digits
    // Examples: +1 (555) 014-9921, +91 9876543210, 555-019-2834
    phone: /^\+?[0-9\s\-()]{10,15}$/,

    // Department: 3-50 chars, alphabets, spaces, and ampersands
    department: /^[a-zA-Z\s&,-]{3,50}$/
};

// ============================================================================
// 2. ERROR MESSAGES SPECIFICATION
// ============================================================================
const VALIDATION_MESSAGES = {
    fullName: {
        required: "Please enter your full name.",
        pattern: "Name must be 3-50 letters only (no numbers or special characters)."
    },
    email: {
        required: "Campus email address is mandatory.",
        pattern: "Please enter a valid campus email ending in @smartcampus.edu"
    },
    studentId: {
        required: "Student ID is required.",
        pattern: "Format must be [DEPT]-[YEAR]-[ROLL] (e.g. CS-2024-8842)"
    },
    department: {
        required: "Please specify your academic department.",
        pattern: "Department name must contain letters only (e.g. Computer Science)"
    },
    password: {
        required: "Password is required.",
        minLength: "Password must be at least 8 characters long.",
        strength: "Password must include at least one uppercase, one lowercase, and one number."
    },
    confirmPassword: {
        required: "Please re-type your password.",
        match: "Passwords do not match."
    },
    phone: {
        required: "Phone number is required.",
        pattern: "Enter a valid 10-15 digit phone number (e.g. +1 555-014-9921)"
    }
};

// ============================================================================
// 3. CORE VALIDATION LOGIC ENGINE
// ============================================================================
class StudentFormValidator {
    constructor(formElementId) {
        this.form = document.getElementById(formElementId);
        if (!this.form) return;

        this.fields = {
            fullName: this.form.querySelector('input[name="full_name"]'),
            email: this.form.querySelector('input[name="email"]'),
            studentId: this.form.querySelector('input[name="student_id"]'),
            department: this.form.querySelector('input[name="department"]'),
            password: this.form.querySelector('input[name="password"]'),
            confirmPassword: this.form.querySelector('input[name="confirm_password"]'),
            phone: this.form.querySelector('input[name="phone"]')
        };

        this.init();
    }

    init() {
        // Attach live input & blur listeners to each registered field
        Object.entries(this.fields).forEach(([fieldName, input]) => {
            if (!input) return;

            // Live validation as user types
            input.addEventListener('input', () => this.validateField(fieldName, false));

            // Strict validation when user moves out of input
            input.addEventListener('blur', () => this.validateField(fieldName, true));
        });

        // Auto-formatter for Student ID (e.g. cs20248842 -> CS-2024-8842)
        if (this.fields.studentId) {
            this.fields.studentId.addEventListener('input', (e) => {
                let val = e.target.value.toUpperCase().replace(/[^A-Z0-9-]/g, '');
                
                // Auto insert hyphen after letters if typed without
                const match = val.match(/^([A-Z]{2,4})(\d{4})(\d{1,5})$/);
                if (match) {
                    val = `${match[1]}-${match[2]}-${match[3]}`;
                }
                e.target.value = val;
            });
        }

        // Live Password Strength Meter
        if (this.fields.password) {
            this.fields.password.addEventListener('input', () => {
                this.updatePasswordStrength(this.fields.password.value);
            });
        }

        // Intercept Form Submission to prevent invalid data transmission
        this.form.addEventListener('submit', (e) => {
            let isFormValid = true;

            Object.keys(this.fields).forEach(fieldName => {
                if (this.fields[fieldName]) {
                    const valid = this.validateField(fieldName, true);
                    if (!valid) isFormValid = false;
                }
            });

            if (!isFormValid) {
                e.preventDefault();
                // Focus first invalid element
                const firstInvalid = this.form.querySelector('.is-invalid');
                if (firstInvalid) {
                    firstInvalid.focus();
                    firstInvalid.scrollIntoView({ behavior: 'smooth', block: 'center' });
                }
            }
        });
    }

    /**
     * Field validator dispatcher
     */
    validateField(fieldName, isBlurEvent) {
        const input = this.fields[fieldName];
        if (!input) return true;

        const val = input.value.trim();
        let isValid = true;
        let errorMsg = '';

        switch (fieldName) {
            case 'fullName':
                if (!val) {
                    if (isBlurEvent) { isValid = false; errorMsg = VALIDATION_MESSAGES.fullName.required; }
                } else if (!STUDENT_VALIDATION_PATTERNS.fullName.test(val)) {
                    isValid = false;
                    errorMsg = VALIDATION_MESSAGES.fullName.pattern;
                }
                break;

            case 'email':
                if (!val) {
                    if (isBlurEvent) { isValid = false; errorMsg = VALIDATION_MESSAGES.email.required; }
                } else if (!STUDENT_VALIDATION_PATTERNS.generalEmail.test(val)) {
                    isValid = false;
                    errorMsg = "Please enter a valid email format (e.g. name@domain.com)";
                } else if (!STUDENT_VALIDATION_PATTERNS.campusEmail.test(val)) {
                    // Soft warning / academic reminder
                    this.setHelperNotice(input, "Note: Official @smartcampus.edu domain is recommended for priority verification.", "amber");
                    isValid = true;
                }
                break;

            case 'studentId':
                if (!val) {
                    // Optional on some forms, but if present must match pattern
                    if (input.hasAttribute('required') && isBlurEvent) {
                        isValid = false;
                        errorMsg = VALIDATION_MESSAGES.studentId.required;
                    }
                } else if (!STUDENT_VALIDATION_PATTERNS.studentId.test(val)) {
                    isValid = false;
                    errorMsg = VALIDATION_MESSAGES.studentId.pattern;
                }
                break;

            case 'department':
                if (!val) {
                    if (input.hasAttribute('required') && isBlurEvent) {
                        isValid = false;
                        errorMsg = VALIDATION_MESSAGES.department.required;
                    }
                } else if (!STUDENT_VALIDATION_PATTERNS.department.test(val)) {
                    isValid = false;
                    errorMsg = VALIDATION_MESSAGES.department.pattern;
                }
                break;

            case 'password':
                if (!val) {
                    if (isBlurEvent) { isValid = false; errorMsg = VALIDATION_MESSAGES.password.required; }
                } else if (val.length < 8) {
                    isValid = false;
                    errorMsg = VALIDATION_MESSAGES.password.minLength;
                } else if (!/[A-Z]/.test(val) || !/[a-z]/.test(val) || !/\d/.test(val)) {
                    isValid = false;
                    errorMsg = VALIDATION_MESSAGES.password.strength;
                }
                // Also trigger confirm password recheck if already filled
                if (this.fields.confirmPassword && this.fields.confirmPassword.value) {
                    this.validateField('confirmPassword', false);
                }
                break;

            case 'confirmPassword':
                const pwd = this.fields.password ? this.fields.password.value : '';
                if (!val) {
                    if (isBlurEvent) { isValid = false; errorMsg = VALIDATION_MESSAGES.confirmPassword.required; }
                } else if (val !== pwd) {
                    isValid = false;
                    errorMsg = VALIDATION_MESSAGES.confirmPassword.match;
                }
                break;

            case 'phone':
                if (val && !STUDENT_VALIDATION_PATTERNS.phone.test(val)) {
                    isValid = false;
                    errorMsg = VALIDATION_MESSAGES.phone.pattern;
                }
                break;
        }

        // Render Visual Styles
        if (!isValid) {
            this.showFieldError(input, errorMsg);
        } else if (val) {
            this.showFieldSuccess(input);
        } else {
            this.clearFieldStatus(input);
        }

        return isValid;
    }

    /**
     * UI Feedback Helpers: Red border, error message text
     */
    showFieldError(input, message) {
        input.classList.add('border-rose-500', 'focus:ring-rose-500/20', 'is-invalid');
        input.classList.remove('border-emerald-500', 'focus:ring-emerald-500/20', 'border-slate-200');

        let errorEl = input.parentElement.querySelector('.field-error-feedback');
        if (!errorEl) {
            errorEl = document.createElement('div');
            errorEl.className = 'field-error-feedback text-[11px] text-rose-600 font-semibold mt-1 flex items-center gap-1';
            input.parentElement.appendChild(errorEl);
        }
        errorEl.innerHTML = `<i class="fas fa-circle-exclamation text-[10px]"></i> <span>${message}</span>`;
    }

    showFieldSuccess(input) {
        input.classList.remove('border-rose-500', 'focus:ring-rose-500/20', 'is-invalid');
        input.classList.add('border-emerald-500', 'focus:ring-emerald-500/20');

        const errorEl = input.parentElement.querySelector('.field-error-feedback');
        if (errorEl) errorEl.remove();
    }

    clearFieldStatus(input) {
        input.classList.remove('border-rose-500', 'focus:ring-rose-500/20', 'border-emerald-500', 'focus:ring-emerald-500/20', 'is-invalid');
        input.classList.add('border-slate-200');

        const errorEl = input.parentElement.querySelector('.field-error-feedback');
        if (errorEl) errorEl.remove();
    }

    setHelperNotice(input, text, color = 'amber') {
        let noticeEl = input.parentElement.querySelector('.field-helper-notice');
        if (!noticeEl) {
            noticeEl = document.createElement('div');
            noticeEl.className = `field-helper-notice text-[11px] text-${color}-600 mt-1 flex items-center gap-1`;
            input.parentElement.appendChild(noticeEl);
        }
        noticeEl.innerHTML = `<i class="fas fa-circle-info text-[10px]"></i> <span>${text}</span>`;
    }

    /**
     * Password Strength Evaluation & Indicator
     */
    updatePasswordStrength(password) {
        const meterContainer = document.getElementById('passwordStrengthContainer');
        if (!meterContainer) return;

        let score = 0;
        if (password.length >= 8) score += 25;
        if (/[A-Z]/.test(password)) score += 25;
        if (/[0-9]/.test(password)) score += 25;
        if (/[^A-Za-z0-9]/.test(password)) score += 25;

        const bar = document.getElementById('passwordStrengthBar');
        const text = document.getElementById('passwordStrengthText');

        if (!bar || !text) return;

        if (password.length === 0) {
            bar.style.width = '0%';
            bar.className = 'h-1.5 rounded-full transition-all duration-300 bg-slate-200';
            text.textContent = '';
        } else if (score <= 25) {
            bar.style.width = '25%';
            bar.className = 'h-1.5 rounded-full transition-all duration-300 bg-rose-500';
            text.innerHTML = '<span class="text-rose-600 font-bold">Weak</span> (Add uppercase, number & symbol)';
        } else if (score <= 50) {
            bar.style.width = '50%';
            bar.className = 'h-1.5 rounded-full transition-all duration-300 bg-amber-500';
            text.innerHTML = '<span class="text-amber-600 font-bold">Fair</span> (Add numbers & special characters)';
        } else if (score <= 75) {
            bar.style.width = '75%';
            bar.className = 'h-1.5 rounded-full transition-all duration-300 bg-blue-500';
            text.innerHTML = '<span class="text-blue-600 font-bold">Good</span> (Add a special symbol for strong)';
        } else {
            bar.style.width = '100%';
            bar.className = 'h-1.5 rounded-full transition-all duration-300 bg-emerald-500';
            text.innerHTML = '<span class="text-emerald-600 font-bold">Strong</span> (Secure password)';
        }
    }
}

// ============================================================================
// 4. AUTO-INITIALIZE ON DOM LOAD
// ============================================================================
document.addEventListener('DOMContentLoaded', () => {
    // 1. Initialize for Student Registration Form
    if (document.getElementById('studentRegisterForm')) {
        new StudentFormValidator('studentRegisterForm');
    }

    // 2. Initialize for Student Profile Form in Dashboard
    if (document.getElementById('studentProfileForm')) {
        new StudentFormValidator('studentProfileForm');
    }
});
