"use client";

import { useState, useEffect } from "react";
import Link from "next/link";
import { Menu, X } from "lucide-react";
import { motion, AnimatePresence } from "framer-motion";

export function MerchantNavbar() {
    const [isScrolled, setIsScrolled] = useState(false);
    const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);

    useEffect(() => {
        const handleScroll = () => {
            setIsScrolled(window.scrollY > 20);
        };
        window.addEventListener("scroll", handleScroll);
        return () => window.removeEventListener("scroll", handleScroll);
    }, []);

    return (
        <>
            <nav
                className={`fixed top-0 left-0 right-0 z-50 transition-all duration-300 ${isScrolled ? "glass-dark shadow-sm py-3" : "bg-secondary py-5"
                    }`}
            >
                <div className="container mx-auto px-6 flex items-center justify-between">
                    {/* Logo */}
                    <Link href="/" className="flex items-center gap-2 group">
                        <div className="w-10 h-10 rounded-xl bg-gradient-to-tr from-primary to-primary-dark flex items-center justify-center text-white font-bold text-xl shadow-lg group-hover:scale-105 transition-transform">
                            M
                        </div>
                        <span className="text-2xl font-bold text-white">
                            MomoPe <span className="text-primary text-sm uppercase tracking-wider ml-1">Business</span>
                        </span>
                    </Link>

                    {/* Desktop Nav */}
                    <div className="hidden md:flex items-center gap-8">
                        <NavLink href="/merchant#features">Features</NavLink>
                        <NavLink href="/merchant#pricing">Pricing</NavLink>
                        <NavLink href="/support">Support</NavLink>

                        <div className="flex items-center gap-4 ml-4">
                            <Link
                                href="/merchant/login"
                                className="text-white hover:text-primary font-medium transition-colors"
                            >
                                Login
                            </Link>
                            <Link
                                href="/merchant/signup"
                                className="bg-primary text-white px-6 py-2.5 rounded-full font-medium hover:bg-primary-dark transition-all shadow-lg hover:shadow-xl hover:-translate-y-0.5"
                            >
                                Sign Up
                            </Link>
                        </div>
                    </div>

                    {/* Mobile Menu Button */}
                    <button
                        className="md:hidden p-2 text-white"
                        onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
                    >
                        {isMobileMenuOpen ? <X size={24} /> : <Menu size={24} />}
                    </button>
                </div>
            </nav>

            {/* Mobile Menu Overlay */}
            <AnimatePresence>
                {isMobileMenuOpen && (
                    <motion.div
                        initial={{ opacity: 0, y: -20 }}
                        animate={{ opacity: 1, y: 0 }}
                        exit={{ opacity: 0, y: -20 }}
                        className="fixed inset-0 z-40 bg-secondary/95 backdrop-blur-xl md:hidden pt-24 px-6 flex flex-col gap-6"
                    >
                        <MobileNavLink onClick={() => setIsMobileMenuOpen(false)} href="/merchant#features">
                            Features
                        </MobileNavLink>
                        <MobileNavLink onClick={() => setIsMobileMenuOpen(false)} href="/merchant#pricing">
                            Pricing
                        </MobileNavLink>
                        <MobileNavLink onClick={() => setIsMobileMenuOpen(false)} href="/support">
                            Support
                        </MobileNavLink>

                        <div className="flex flex-col gap-4 mt-8">
                            <Link
                                href="/merchant/login"
                                onClick={() => setIsMobileMenuOpen(false)}
                                className="w-full py-4 text-center text-white border border-white/20 rounded-xl font-medium"
                            >
                                Login
                            </Link>
                            <Link
                                href="/merchant/signup"
                                onClick={() => setIsMobileMenuOpen(false)}
                                className="w-full py-4 text-center bg-primary text-white rounded-xl font-bold shadow-lg"
                            >
                                Sign Up Free
                            </Link>
                        </div>
                    </motion.div>
                )}
            </AnimatePresence>
        </>
    );
}

function NavLink({ href, children }: { href: string; children: React.ReactNode }) {
    return (
        <Link
            href={href}
            className="text-gray-300 hover:text-white font-medium transition-colors relative group"
        >
            {children}
            <span className="absolute -bottom-1 left-0 w-0 h-0.5 bg-primary transition-all group-hover:w-full" />
        </Link>
    );
}

function MobileNavLink({
    href,
    children,
    onClick,
}: {
    href: string;
    children: React.ReactNode;
    onClick: () => void;
}) {
    return (
        <Link
            href={href}
            onClick={onClick}
            className="text-2xl font-bold text-white border-b border-white/10 pb-4"
        >
            {children}
        </Link>
    );
}
