/**
 * Header Branding Component (Logo + Title)
 * Clean, minimal branding
 */

import { Link } from 'react-router-dom';

export function HeaderBranding() {
  return (
    <Link to="/" className="flex items-center gap-2.5 group cursor-pointer-custom shrink-0">
      {/* Logo */}
      <div className="relative w-8 h-8 shrink-0">
        <img
          src={`${import.meta.env.BASE_URL}images/logo.png`}
          alt="eMark Logo"
          className="w-full h-full rounded-lg transition-transform duration-300 group-hover:scale-105 object-contain"
        />
      </div>
      {/* Brand Name */}
      <span className="text-xl font-bold gradient-text">eMark</span>
    </Link>
  );
}
