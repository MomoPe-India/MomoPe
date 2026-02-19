"use client";

import { useState, useEffect } from "react";
import Link from "next/link";
import Image from "next/image";
import { usePathname } from "next/navigation";
import { Menu, X, Smartphone, Twitter, Instagram, Linkedin, Facebook } from "lucide-react";
import { motion, AnimatePresence } from "framer-motion";

interface NavbarProps {
    theme?: 'light' | 'dark';
}

export function Navbar({ }: NavbarProps) {
    const [isScrolled, setIsScrolled] = useState(false);
    const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);

    useEffect(() => {
        const handleScroll = () => {
            setIsScrolled(window.scrollY > 20);
        };
        window.addEventListener("scroll", handleScroll);
        return () => window.removeEventListener("scroll", handleScroll);
    }, []);

    const pathname = usePathname();

    // Default to 'dark' theme for Home and Merchant pages (Purple Hero), 'light' for others.
    const effectiveTheme = (pathname === '/' || pathname === '/merchant') ? 'dark' : 'light';

    // Special case: Merchant page requests high-contrast (Pure White) logo
    const isHighContrast = pathname === '/merchant';

    const handleScrollTop = (e: React.MouseEvent<HTMLAnchorElement>) => {
        if (pathname === '/') {
            e.preventDefault();
            window.scrollTo({ top: 0, behavior: 'smooth' });
        }
    };

    // If scroll is active OR mobile menu is open, we want the "Light" header look (Colored Logo)
    const isDarkHeader = effectiveTheme === 'dark' && !isScrolled && !isMobileMenuOpen;

    // const logoTextMain = isDarkHeader ? "text-white" : "text-[#35255e]"; // Unused
    const mobileMenuBtnColor = isDarkHeader ? "text-white" : "text-[#35255e]";
    const navLinkClass = isDarkHeader ? "text-white/90 hover:text-white" : "text-gray-600 hover:text-[#35255e]";

    return (
        <>
            <motion.nav
                initial={{ y: -100 }}
                animate={{ y: 0 }}
                className={`fixed top-0 left-0 right-0 z-50 transition-all duration-300 ${isScrolled || isMobileMenuOpen
                    ? "bg-white/80 backdrop-blur-xl border-b border-gray-200/50 shadow-sm py-2.5"
                    : "bg-transparent py-4"
                    }`}
            >
                <div className="container mx-auto px-6 flex items-center justify-between">

                    {/* Logo Section */}
                    <Link href="/" onClick={handleScrollTop} className="flex items-center gap-2 group relative z-50">
                        <div className="relative w-40 h-12 md:w-44 md:h-14 transition-transform group-hover:scale-105">
                            <Image
                                src={isDarkHeader ? "/images/momope_complete_logo_2.png" : "/images/momope_complete_logo_1.png"}
                                alt="MomoPe Logo"
                                fill
                                className="object-contain object-left"
                                style={isHighContrast && isDarkHeader ? { filter: 'brightness(0) invert(1)' } : undefined}
                                priority
                            />
                        </div>
                    </Link>

                    {/* Desktop Menu */}
                    <div className="hidden md:flex items-center gap-5 lg:gap-8">
                        <NavLink href="/" className={navLinkClass} onClick={handleScrollTop}>Home</NavLink>
                        <NavLink href="/merchant" className={navLinkClass}>Merchant</NavLink>
                        <NavLink href="/about" className={navLinkClass}>About Us</NavLink>
                        <NavLink href="/careers" className={navLinkClass}>Careers</NavLink>
                        <NavLink href="/contact" className={navLinkClass}>Contact</NavLink>
                    </div>

                    {/* Desktop CTA */}
                    <div className="hidden md:block">
                        <Link
                            href="https://whatsapp.com/channel/0029VbBhoLk7z4kiZU9cBz1U"
                            target="_blank"
                            className="group relative overflow-hidden bg-gradient-to-r from-[#00C4A7] to-[#00a88e] text-white px-6 py-2.5 rounded-full font-bold text-sm shadow-xl shadow-teal-500/20 hover:shadow-teal-500/40 transition-all active:scale-95 flex items-center gap-2 hover:-translate-y-0.5"
                        >
                            <span className="absolute inset-0 bg-white/20 translate-y-full group-hover:translate-y-0 transition-transform duration-300" />
                            <span className="relative flex items-center gap-2">
                                <Smartphone size={16} className="animate-pulse" />
                                Get App
                            </span>
                        </Link>
                    </div>

                    {/* Mobile Menu Button */}
                    <button
                        className={`relative z-50 p-2 md:hidden hover:bg-white/10 rounded-full transition-colors ${mobileMenuBtnColor}`}
                        onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
                    >
                        {isMobileMenuOpen ? <X size={28} /> : <Menu size={28} />}
                    </button>
                </div>
            </motion.nav>

            {/* Premium Mobile Menu Overlay */}
            <AnimatePresence>
                {isMobileMenuOpen && (
                    <motion.div
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        exit={{ opacity: 0 }}
                        transition={{ duration: 0.3 }}
                        className="fixed inset-0 z-40 bg-white/95 backdrop-blur-3xl md:hidden flex flex-col"
                    >
                        {/* Decorative Background Blob */}
                        <div className="absolute top-0 right-0 w-64 h-64 bg-teal-500/10 rounded-full blur-[80px] pointer-events-none" />
                        <div className="absolute bottom-0 left-0 w-64 h-64 bg-purple-500/10 rounded-full blur-[80px] pointer-events-none" />

                        {/* Menu Content Container */}
                        <div className="flex flex-col h-full pt-32 px-8 pb-32 overflow-y-auto relative z-10">

                            {/* Navigation Links */}
                            <motion.div
                                initial="hidden"
                                animate="visible"
                                variants={{
                                    hidden: { opacity: 0 },
                                    visible: {
                                        opacity: 1,
                                        transition: {
                                            staggerChildren: 0.1
                                        }
                                    }
                                }}
                                className="flex flex-col gap-6"
                            >
                                <MobileNavLink href="/" onClick={() => setIsMobileMenuOpen(false)}>Home</MobileNavLink>
                                <MobileNavLink href="/merchant" onClick={() => setIsMobileMenuOpen(false)}>For Merchants</MobileNavLink>
                                <MobileNavLink href="/about" onClick={() => setIsMobileMenuOpen(false)}>About Us</MobileNavLink>
                                <MobileNavLink href="/careers" onClick={() => setIsMobileMenuOpen(false)}>Careers</MobileNavLink>
                                <MobileNavLink href="/contact" onClick={() => setIsMobileMenuOpen(false)}>Contact</MobileNavLink>
                            </motion.div>

                            {/* Footer / CTA Section */}
                            <motion.div
                                initial={{ opacity: 0, y: 20 }}
                                animate={{ opacity: 1, y: 0 }}
                                transition={{ delay: 0.5, duration: 0.5 }}
                                className="mt-auto pt-10"
                            >
                                <Link
                                    href="https://whatsapp.com/channel/0029VbBhoLk7z4kiZU9cBz1U"
                                    onClick={() => setIsMobileMenuOpen(false)}
                                    target="_blank"
                                    className="w-full bg-[#00C4A7] text-white py-5 rounded-2xl font-bold text-xl text-center shadow-lg shadow-teal-500/20 active:scale-95 transition-transform flex items-center justify-center gap-3 mb-8"
                                >
                                    <Smartphone size={24} />
                                    Get the App
                                </Link>

                                <div className="border-t border-gray-100 pt-8 mt-auto pb-10">
                                    <p className="text-gray-400 text-sm font-medium mb-6 uppercase tracking-widest text-center">Follow Us</p>
                                    <div className="flex justify-center gap-6 mb-8">
                                        <SocialLink href="https://x.com/MomoPe_Deals" icon={<Twitter size={20} />} />
                                        <SocialLink href="https://www.linkedin.com/company/momope/" icon={<Linkedin size={20} />} />
                                        <SocialLink href="https://www.instagram.com/momope_india/" icon={<Instagram size={20} />} />
                                        <SocialLink href="https://www.facebook.com/MomoPe.india" icon={<Facebook size={20} />} />
                                    </div>
                                    <p className="text-center text-gray-400 text-xs">
                                        © 2026 MomoPe Digital Hub Pvt. Ltd.<br />All rights reserved.
                                    </p>
                                </div>
                            </motion.div>
                        </div>
                    </motion.div>
                )}
            </AnimatePresence>
        </>
    );
}

function NavLink({ href, children, className, onClick }: { href: string; children: React.ReactNode; className?: string; onClick?: (e: React.MouseEvent<HTMLAnchorElement>) => void }) {
    return (
        <Link
            href={href}
            onClick={onClick}
            className={`text-[15px] font-medium tracking-wide transition-colors relative group ${className || "text-gray-600 hover:text-[#35255e]"}`}
        >
            {children}
            <span className="absolute -bottom-1 left-1/2 w-0 h-0.5 bg-[#00C4A7] transition-all duration-300 group-hover:w-full group-hover:left-0" />
        </Link>
    );
}

function MobileNavLink({ href, onClick, children }: { href: string; onClick: () => void; children: React.ReactNode }) {
    return (
        <motion.div
            variants={{
                hidden: { opacity: 0, x: -20 },
                visible: { opacity: 1, x: 0 }
            }}
        >
            <Link
                href={href}
                onClick={onClick}
                className="text-4xl font-black text-[#35255e] py-3 block hover:text-[#00C4A7] transition-colors tracking-tight"
            >
                {children}
            </Link>
        </motion.div>
    );
}

function SocialLink({ href, icon }: { href: string, icon: React.ReactNode }) {
    return (
        <a href={href} target="_blank" rel="noopener noreferrer" className="w-12 h-12 rounded-full bg-gray-50 flex items-center justify-center text-gray-400 font-bold text-lg hover:bg-[#35255e] hover:text-white transition-all shadow-sm">
            {icon}
        </a>
    )
}
