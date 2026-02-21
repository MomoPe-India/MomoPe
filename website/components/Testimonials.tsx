"use client";

import Image from "next/image";
import { Star, Quote, ChevronLeft, ChevronRight } from "lucide-react";
import { useRef } from "react";

const TESTIMONIALS = [
    {
        name: "Rahul Reddy",
        role: "Student, Kadapa",
        text: "I save at least ₹500 every month just by paying with MomoPe at my regular chai shop. The coin rewards are actually useful!",
        image: "https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=400&h=400&fit=crop&q=80",
        rating: 5
    },
    {
        name: "Priya Sharma",
        role: "Software Engineer",
        text: "The app is super smooth. No clutter, just payments and rewards. Finally an app that doesn't spam me with ads or loans.",
        image: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&h=400&fit=crop&q=80",
        rating: 5
    },
    {
        name: "Suresh Babu",
        role: "Cafe Owner",
        text: "Since joining MomoPe, my repeat customers have increased by 30%. The dashboard helps me understand my peak hours perfectly.",
        image: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400&h=400&fit=crop&q=80",
        rating: 5
    },
    {
        name: "Anitha Rao",
        role: "Home Maker",
        text: "I love that I can use MomoPe for everything - groceries, milk, even the auto. And the cashback is instant, not &apos;better luck next time&apos;.",
        image: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400&h=400&fit=crop&q=80",
        rating: 5
    },
    {
        name: "Karthik J",
        role: "Freelancer",
        text: "The best part is the privacy. I don't feel like I'm being tracked. It's just a clean, honest payment app made for our city.",
        image: "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400&h=400&fit=crop&q=80",
        rating: 4
    }
];

export function Testimonials() {
    const scrollRef = useRef<HTMLDivElement>(null);

    const scroll = (direction: 'left' | 'right') => {
        if (scrollRef.current) {
            const { current } = scrollRef;
            const scrollAmount = direction === 'left' ? -400 : 400;
            current.scrollBy({ left: scrollAmount, behavior: 'smooth' });
        }
    };

    return (
        <section className="py-24 bg-surface overflow-hidden relative">
            <div className="container mx-auto px-6 mb-12 flex flex-col md:flex-row items-end justify-between gap-6">
                <div className="max-w-xl">
                    <div className="inline-block px-4 py-1.5 rounded-full bg-orange-50 text-orange-600 font-bold text-sm mb-6 border border-orange-100">
                        Community Love
                    </div>
                    <h2 className="text-4xl md:text-5xl font-black text-[#35255e] mb-4">Loved by Locals</h2>
                    <p className="text-gray-500 text-lg">Real stories from the people building Kadapa&apos;s digital economy.</p>
                </div>

                <div className="flex gap-4">
                    <button onClick={() => scroll('left')} aria-label="Previous testimonial" className="p-3 rounded-full bg-white border border-gray-200 text-gray-600 hover:bg-[#35255e] hover:text-white transition-all shadow-sm hover:shadow-lg">
                        <ChevronLeft size={24} />
                    </button>
                    <button onClick={() => scroll('right')} aria-label="Next testimonial" className="p-3 rounded-full bg-white border border-gray-200 text-gray-600 hover:bg-[#35255e] hover:text-white transition-all shadow-sm hover:shadow-lg">
                        <ChevronRight size={24} />
                    </button>
                </div>
            </div>

            {/* Scrolling Cards Container */}
            <div
                ref={scrollRef}
                className="flex gap-8 overflow-x-auto pb-16 px-6 snap-x no-scrollbar"
                style={{ scrollbarWidth: 'none', msOverflowStyle: 'none' }}
            >
                {TESTIMONIALS.map((t, i) => (
                    <article
                        key={i}
                        className="min-w-[350px] md:min-w-[450px] p-8 md:p-10 bg-white rounded-[3.5rem] border border-gray-100 snap-center shadow-umbra-lg hover:shadow-2xl hover:shadow-primary/10 transition-all duration-500 relative group flex flex-col"
                    >
                        {/* Quotemark */}
                        <div className="absolute top-8 right-8 text-primary/10 group-hover:text-primary/20 transition-colors">
                            <Quote size={64} fill="currentColor" />
                        </div>

                        <div className="flex gap-1 text-orange-400 mb-8">
                            {[...Array(5)].map((_, i) => (
                                <Star key={i} size={18} fill={i < t.rating ? "currentColor" : "none"} className={i < t.rating ? "" : "text-gray-200"} />
                            ))}
                        </div>

                        <p className="text-[#35255e] text-xl leading-relaxed mb-10 font-medium z-10">
                            &quot;{t.text}&quot;
                        </p>

                        <div className="mt-auto flex items-center gap-4">
                            <div className="w-14 h-14 rounded-full bg-gray-200 overflow-hidden relative border-2 border-white shadow-md">
                                <Image
                                    src={t.image}
                                    alt={t.name}
                                    fill
                                    className="object-cover"
                                    unoptimized
                                />
                            </div>
                            <div>
                                <div className="font-bold text-[#35255e] text-lg">{t.name}</div>
                                <div className="text-sm text-primary font-bold uppercase tracking-wider">{t.role}</div>
                            </div>
                        </div>
                    </article>
                ))}
            </div>
        </section>
    );
}
