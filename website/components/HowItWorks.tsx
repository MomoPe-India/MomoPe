"use client";

import { motion } from "framer-motion";
import { Check, Sparkles } from "lucide-react";

export function HowItWorks() {
    return (
        <section className="py-28 bg-[#F8FAFC] relative overflow-hidden">
            {/* Background Decorations */}
            <div className="absolute top-0 left-0 w-full h-full overflow-hidden pointer-events-none">
                <div className="absolute top-[10%] left-[5%] w-64 h-64 bg-primary/5 rounded-full blur-3xl" />
                <div className="absolute bottom-[10%] right-[5%] w-80 h-80 bg-purple-500/5 rounded-full blur-3xl" />
            </div>

            <div className="container mx-auto px-6 relative z-10">
                <div className="text-center max-w-3xl mx-auto mb-20">
                    <motion.span
                        initial={{ opacity: 0, y: 20 }}
                        whileInView={{ opacity: 1, y: 0 }}
                        viewport={{ once: true }}
                        className="inline-block px-4 py-1.5 rounded-full bg-white/50 border border-gray-200 text-primary font-bold tracking-wider uppercase text-xs mb-4 backdrop-blur-sm"
                    >
                        Simple Process
                    </motion.span>
                    <motion.h2
                        initial={{ opacity: 0, y: 20 }}
                        whileInView={{ opacity: 1, y: 0 }}
                        viewport={{ once: true }}
                        transition={{ delay: 0.1 }}
                        className="text-4xl md:text-6xl font-black text-[#35255e] mb-6 leading-tight"
                    >
                        Pay like normal. <br />
                        <span className="text-transparent bg-clip-text bg-gradient-to-r from-primary to-emerald-500">Earn like never before.</span>
                    </motion.h2>
                    <motion.p
                        initial={{ opacity: 0, y: 20 }}
                        whileInView={{ opacity: 1, y: 0 }}
                        viewport={{ once: true }}
                        transition={{ delay: 0.2 }}
                        className="text-gray-500 text-xl font-medium"
                    >
                        No wallets to load. No scratch cards to scratch. Just guaranteed rewards.
                    </motion.p>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-3 gap-8 md:gap-12 relative">
                    {/* Connector Line (Desktop) */}
                    <div className="hidden md:block absolute top-[40%] left-[16%] right-[16%] h-1 bg-gradient-to-r from-gray-200 via-primary/20 to-gray-200 -z-10 rounded-full" />

                    <StepCard
                        number="01"
                        title="Scan & Pay"
                        desc="Scan any MomoPe QR at local stores. Works seamlessly with your existing UPI apps."
                        illustration={<ScanIllustration />}
                    />
                    <StepCard
                        number="02"
                        title="Auto-Apply Coins"
                        desc="Your coin balance is automatically detected. Pay up to 80% of the bill using coins."
                        illustration={<CoinStackIllustration />}
                    />
                    <StepCard
                        number="03"
                        title="Instant Rewards"
                        desc="Get 2-10% cashback as new coins instantly. No waiting, no 'better luck next time'."
                        illustration={<RewardBurstIllustration />}
                    />
                </div>
            </div>
        </section>
    );
}

function StepCard({ number, title, desc, illustration }: { number: string, title: string, desc: string, illustration: React.ReactNode }) {
    return (
        <motion.div
            initial={{ opacity: 0, y: 30 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            whileHover={{ y: -10 }}
            className="group flex flex-col items-center text-center bg-white p-2 rounded-[2.5rem] shadow-soft border border-white/60 relative hover:shadow-2xl transition-all duration-500"
        >
            {/* Illustration Display */}
            <div className="w-full h-80 bg-gradient-to-b from-gray-50 to-white rounded-[2rem] mb-8 overflow-hidden relative flex items-center justify-center border border-gray-100 group-hover:border-primary/20 transition-colors">
                {illustration}
            </div>

            <div className="px-6 pb-8">
                <div className="inline-flex items-center justify-center w-12 h-12 rounded-full bg-[#35255e] text-white font-bold text-lg mb-6 shadow-lg shadow-purple-900/20 group-hover:scale-110 transition-transform">
                    {number}
                </div>
                <h3 className="text-2xl font-bold text-[#35255e] mb-3 group-hover:text-primary transition-colors">{title}</h3>
                <p className="text-gray-500 leading-relaxed font-medium">
                    {desc}
                </p>
            </div>
        </motion.div>
    );
}

// --- Advanced "Wow" Animations ---

function ScanIllustration() {
    return (
        <div className="relative w-full h-full flex items-center justify-center perspective-1000">
            {/* Abstract Grid Background */}
            <div className="absolute inset-0 grid grid-cols-6 grid-rows-6 opacity-10 pointer-events-none">
                {[...Array(36)].map((_, i) => (
                    <div key={i} className="border border-indigo-500/20" />
                ))}
            </div>

            {/* Phone Container with 3D Tilt */}
            <motion.div
                animate={{
                    rotateX: [5, 0, 5],
                    rotateY: [-5, 5, -5],
                    y: [-5, 5, -5]
                }}
                transition={{ duration: 6, repeat: Infinity, ease: "easeInOut" }}
                className="relative w-40 h-72 bg-gray-900 rounded-[2.5rem] border-[6px] border-gray-800 shadow-2xl flex items-center justify-center overflow-hidden z-20 transform-preserve-3d"
            >
                {/* Screen */}
                <div className="absolute inset-0 bg-gray-800/90 flex flex-col items-center justify-center relative">

                    {/* QR Code */}
                    <div className="relative w-28 h-28 bg-white p-2 rounded-lg grid grid-cols-2 gap-1 mb-4">
                        <div className="bg-black rounded-sm" />
                        <div className="bg-black rounded-sm opacity-50" />
                        <div className="bg-black rounded-sm opacity-50" />
                        <div className="bg-black rounded-sm" />

                        {/* Scanning Laser */}
                        <motion.div
                            animate={{ top: ["0%", "120%", "0%"], opacity: [0, 1, 0] }}
                            transition={{ duration: 2, repeat: Infinity, ease: "linear" }}
                            className="absolute left-0 right-0 h-1 bg-primary blur-[2px] shadow-[0_0_15px_#00C4A7]"
                        />
                    </div>

                    {/* Success Check overlay */}
                    <motion.div
                        animate={{ scale: [0, 1.2, 1], opacity: [0, 1, 0] }}
                        transition={{ duration: 2, times: [0.8, 0.9, 1], repeat: Infinity, repeatDelay: 0 }}
                        className="absolute inset-0 bg-emerald-500/90 flex items-center justify-center backdrop-blur-sm"
                    >
                        <div className="w-16 h-16 rounded-full bg-white text-emerald-600 flex items-center justify-center shadow-lg">
                            <Check size={40} strokeWidth={4} />
                        </div>
                    </motion.div>
                </div>

                {/* Notch */}
                <div className="absolute top-3 w-20 h-5 bg-black rounded-full z-20" />
            </motion.div>

            {/* Floating Elements behind */}
            <motion.div
                animate={{ scale: [1, 1.2, 1], opacity: [0.3, 0.6, 0.3] }}
                transition={{ duration: 3, repeat: Infinity }}
                className="absolute w-56 h-56 bg-primary/20 rounded-full blur-2xl -z-10"
            />
        </div>
    );
}

function CoinStackIllustration() {
    return (
        <div className="relative w-full h-full flex items-center justify-center">
            {/* Dynamic Stack Base */}
            <div className="absolute bottom-12 w-28 h-8 bg-black/10 rounded-[100%] blur-sm" />

            {/* Falling Coins Sequence */}
            {[0, 1, 2].map((i) => (
                <motion.div
                    key={i}
                    animate={{
                        y: [-300, 0, 0, 0],
                        opacity: [0, 1, 1, 0],
                        scaleY: [1, 0.6, 1, 1]
                    }}
                    transition={{
                        duration: 3,
                        repeat: Infinity,
                        delay: i * 0.8,
                        times: [0, 0.2, 0.8, 1]
                    }}
                    className="absolute bottom-14 z-10"
                    style={{ marginBottom: i * 14 }} // Stack offset
                >
                    <div className="w-20 h-20 rounded-full bg-gradient-to-b from-amber-300 to-amber-500 border-[3px] border-amber-600 shadow-[0_4px_0_rgb(180,83,9)] flex items-center justify-center text-amber-900 font-black text-3xl">
                        ₹
                        <div className="absolute inset-2 rounded-full border border-white/40" />
                    </div>
                </motion.div>
            ))}

            {/* Impact Ripple */}
            <motion.div
                animate={{ scale: [1, 2], opacity: [1, 0] }}
                transition={{ duration: 0.8, repeat: Infinity, repeatDelay: 0.8 * 2.75 }} // Timing match approx
                className="absolute bottom-10 w-24 h-8 border-2 border-amber-400 rounded-[100%]"
            />

            {/* Swinging Discount Tag */}
            <motion.div
                animate={{ rotate: [-8, 8, -8] }}
                transition={{ duration: 2, repeat: Infinity, ease: "easeInOut" }}
                className="absolute top-10 right-8 origin-top bg-white border-2 border-dashed border-green-500 text-green-600 px-4 py-2 rounded-lg font-bold shadow-lg transform rotate-3"
            >
                <div className="absolute -top-3 left-1/2 -translate-x-1/2 w-1 h-3 bg-gray-300" />
                <div className="w-2 h-2 rounded-full bg-gray-400 absolute -top-4 left-1/2 -translate-x-1/2" />
                80% OFF
            </motion.div>
        </div>
    );
}

function RewardBurstIllustration() {
    return (
        <div className="relative w-full h-full flex items-center justify-center overflow-hidden">
            {/* Rotating God Rays */}
            <motion.div
                animate={{ rotate: 360 }}
                transition={{ duration: 20, repeat: Infinity, ease: "linear" }}
                className="absolute inset-0 flex items-center justify-center opacity-30 pointer-events-none"
            >
                {[...Array(8)].map((_, i) => (
                    <div
                        key={i}
                        className="absolute w-12 h-[200%] bg-gradient-to-t from-primary/30 to-transparent origin-bottom"
                        style={{ rotate: `${i * 45}deg`, bottom: '50%' }}
                    />
                ))}
            </motion.div>

            {/* Jumping Chest */}
            <motion.div
                animate={{
                    y: [0, -15, 0],
                    scale: [1, 1.05, 1],
                    rotate: [-2, 2, -2]
                }}
                transition={{ duration: 0.8, repeat: Infinity, repeatDelay: 0.5 }}
                className="relative z-20 mt-10"
            >
                {/* Chest Body */}
                <div className="w-32 h-20 bg-gradient-to-r from-purple-600 to-indigo-700 rounded-b-xl border-4 border-indigo-900 relative shadow-2xl">
                    <div className="absolute inset-x-10 top-0 bottom-0 bg-purple-800/50" /> {/* Vertical Band */}
                    <div className="absolute inset-0 flex items-center justify-center">
                        <div className="w-6 h-6 rounded-full bg-yellow-400 shadow-lg border border-yellow-600" /> {/* Lock */}
                    </div>
                </div>

                {/* Chest Lid - Flapping Open */}
                <motion.div
                    animate={{ rotateX: [0, -60, 0] }}
                    transition={{ duration: 0.8, repeat: Infinity, repeatDelay: 0.5 }}
                    className="absolute -top-8 left-[-4px] right-[-4px] h-10 bg-gradient-to-r from-purple-500 to-indigo-600 rounded-t-xl border-4 border-indigo-900 origin-bottom"
                >
                    <div className="absolute inset-x-11 top-0 bottom-0 bg-purple-800/50" />
                </motion.div>
            </motion.div>

            {/* Explosive Complex Confetti */}
            {[...Array(15)].map((_, i) => (
                <motion.div
                    key={`p-${i}`}
                    animate={{
                        y: [20, -150, 50],
                        x: [0, ((i % 5) - 2) * 50, 0],
                        opacity: [1, 1, 0],
                        rotate: [0, 720],
                        scale: [0, 1.5, 0]
                    }}
                    transition={{ duration: 2, repeat: Infinity, delay: (i * 0.2) % 1.5 }}
                    className={`absolute z-10 w-4 h-4 ${i % 4 === 0 ? 'bg-yellow-400 rounded-full' :
                        i % 4 === 1 ? 'bg-pink-500 rounded-sm' :
                            i % 4 === 2 ? 'bg-cyan-400 clip-path-triangle' : 'bg-green-400'
                        }`}
                    style={{
                        clipPath: i % 4 === 2 ? 'polygon(50% 0%, 0% 100%, 100% 100%)' : 'none'
                    }}
                />
            ))}

            {/* Glow Burst */}
            <motion.div
                animate={{ scale: [0.5, 2, 0.5], opacity: [0.2, 0.6, 0.2] }}
                transition={{ duration: 1.5, repeat: Infinity }}
                className="absolute z-0 w-48 h-48 bg-yellow-400/30 rounded-full blur-3xl mix-blend-screen"
            />
        </div>
    );
}
