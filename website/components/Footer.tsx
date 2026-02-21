import Link from "next/link";
import Image from "next/image";
import { Facebook, Twitter, Instagram, Linkedin, MapPin, Mail } from "lucide-react";

export function Footer() {
    return (
        <footer className="bg-[#0B0F19] text-white pt-12 pb-8 border-t border-gray-900 relative overflow-hidden">
            {/* Watermark - Increased visibility (5%) */}
            <div className="absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 text-[120px] font-black text-white/5 pointer-events-none select-none tracking-tighter whitespace-nowrap z-0">
                MOMOPE
            </div>

            <div className="container mx-auto px-6 relative z-10">

                {/* Top Section: Brand & Socials */}
                <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-8 mb-10 pb-8 border-b border-gray-800">
                    <div className="flex items-center gap-3 group mb-6">
                        <div className="relative w-32 h-10 md:w-40 md:h-12 transition-transform group-hover:scale-105 -ml-2 md:-ml-5">
                            <Image
                                src="/images/momope_complete_logo_2.png"
                                alt="MomoPe Logo"
                                fill
                                className="object-contain"
                            />
                        </div>
                    </div>

                    <div className="flex gap-4">
                        <SocialIcon icon={<Twitter size={18} />} href="https://x.com/MomoPe_Deals" />
                        <SocialIcon icon={<Linkedin size={18} />} href="https://www.linkedin.com/company/momope/" />
                        <SocialIcon icon={<Instagram size={18} />} href="https://www.instagram.com/momope_india/" />
                        <SocialIcon icon={<Facebook size={18} />} href="https://www.facebook.com/MomoPe.india" />
                    </div>
                </div>

                {/* Main Grid */}
                <div className="grid grid-cols-2 md:grid-cols-4 gap-12 lg:gap-8 mb-12">

                    {/* Column 1: Company */}
                    <div>
                        <h4 className="font-bold text-white mb-6 text-lg">Company</h4>
                        <ul className="space-y-4 text-base text-gray-400">
                            <li><NavLink href="/about">About Us</NavLink></li>
                            <li><NavLink href="/careers">Careers</NavLink></li>
                            <li><NavLink href="/investors">Investors</NavLink></li>
                            <li><NavLink href="/media-kit">Media Kit</NavLink></li>
                            <li><NavLink href="/contact">Contact Us</NavLink></li>
                        </ul>
                    </div>

                    {/* Column 2: Product */}
                    <div>
                        <h4 className="font-bold text-white mb-6 text-lg">Product</h4>
                        <ul className="space-y-4 text-base text-gray-400">
                            <li><NavLink href="/merchant">For Merchants</NavLink></li>
                            <li><NavLink href="/#download">For Consumers</NavLink></li>
                            <li><NavLink href="/referral-program">Referral Program</NavLink></li>
                            <li><NavLink href="/merchant">Merchant Login</NavLink></li>
                        </ul>
                    </div>

                    {/* Column 3: Legal & Support */}
                    <div>
                        <h4 className="font-bold text-white mb-6 text-lg">Resources</h4>
                        <ul className="space-y-4 text-base text-gray-400">
                            <li><NavLink href="/support">Help Center</NavLink></li>
                            <li><NavLink href="/privacy">Privacy Policy</NavLink></li>
                            <li><NavLink href="/terms">Terms of Service</NavLink></li>
                            <li><NavLink href="/sitemap.xml">Sitemap</NavLink></li>
                        </ul>
                    </div>

                    {/* Column 4: Office */}
                    <div>
                        <h4 className="font-bold text-white mb-6 text-lg">Registered Office</h4>
                        <div className="space-y-4 text-base text-gray-400 leading-relaxed">
                            <p>
                                <span className="block text-white font-medium mb-1">MomoPe Digital Hub Pvt. Ltd.</span>
                                #4/106, Krishnapuram, Kadapa,<br />
                                Andhra Pradesh, India - 516003
                            </p>
                            <div className="flex items-center gap-2 mt-4">
                                <Mail size={16} className="text-[#00C4A7]" />
                                <a href="mailto:support@momope.com" className="hover:text-white transition-colors">support@momope.com</a>
                            </div>
                        </div>

                        <div className="mt-8 flex gap-3">
                            <StoreBadge type="google" />
                            <StoreBadge type="apple" />
                        </div>
                    </div>
                </div>

                {/* Bottom Bar */}
                <div className="pt-8 border-t border-gray-800 flex flex-col md:flex-row justify-between items-center gap-6 text-xs text-white opacity-80">
                    <div className="flex flex-col md:flex-row gap-4 items-center">
                        <p>&copy; 2026 MomoPe Digital Hub Pvt. Ltd. All rights reserved.</p>
                        <span className="hidden md:inline text-white/40">|</span>
                        <p>CIN: U63120AP2025PTC118821</p>
                    </div>

                    <div className="flex items-center gap-2">
                        <span className="text-white">Made in India</span>
                        {/* Indian Flag SVG */}
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 900 600" className="w-6 h-4 rounded-sm shadow-sm opacity-90">
                            <path fill="#f93" d="M0 0h900v200H0z" />
                            <path fill="#fff" d="M0 200h900v200H0z" />
                            <path fill="#006c35" d="M0 400h900v200H0z" />
                            <g transform="translate(450 300)">
                                <circle r="92.5" fill="none" stroke="#000080" strokeWidth="24" />
                                <g stroke="#000080" strokeWidth="12">
                                    <path d="M0-85v170M42.5-73.6l-85 147.2M73.6-42.5l-147.2 85M85 0h-170M73.6 42.5l-147.2-85M42.5 73.6l-85-147.2M0 85v-170M-42.5 73.6l85-147.2M-73.6 42.5l147.2-85M-85 0h170M-73.6-42.5l147.2 85M-42.5-73.6l85 147.2" />
                                </g>
                                <circle r="16" fill="#000080" />
                            </g>
                        </svg>
                    </div>
                </div>
            </div>
        </footer>
    );
}

function NavLink({ href, children }: { href: string; children: React.ReactNode }) {
    return (
        <Link href={href} className="hover:text-[#00C4A7] transition-colors block w-fit">
            {children}
        </Link>
    );
}

function SocialIcon({ icon, href }: { icon: React.ReactNode; href: string }) {
    return (
        <a
            href={href}
            target="_blank"
            rel="noopener noreferrer"
            className="w-10 h-10 rounded-full border border-gray-800 text-gray-400 flex items-center justify-center hover:bg-white hover:text-[#0B0F19] hover:border-white transition-all duration-300"
        >
            {icon}
        </a>
    );
}

function StoreBadge({ type }: { type: 'google' | 'apple' }) {
    const isGoogle = type === 'google';
    return (
        <button className="flex items-center justify-center w-10 h-10 bg-gray-800 rounded-lg text-gray-400 hover:bg-white hover:text-[#0B0F19] transition-all border border-gray-700 hover:border-white">
            {isGoogle ? (
                <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/android/android-original.svg" alt="Google Play" className="w-5 h-5 filter grayscale brightness-200 contrast-0 group-hover:brightness-0" style={{ filter: 'grayscale(1) brightness(1.5)' }} />
            ) : (
                <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/apple/apple-original.svg" alt="App Store" className="w-5 h-5 filter grayscale brightness-200 contrast-0 group-hover:brightness-0" style={{ filter: 'grayscale(1) brightness(1.5)' }} />
            )}
        </button>
    )
}
