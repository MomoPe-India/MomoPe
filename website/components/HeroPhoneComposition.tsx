"use client";

import { motion } from "framer-motion";
import { TrendingUp, Shield, Zap, CreditCard, ShoppingBag, Coffee } from "lucide-react";

export function HeroPhoneComposition() {
    return (
        <div className="relative w-full h-[600px] flex items-center justify-center perspective-1000">

            {/* Ambient Glow Behind */}
            <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[300px] h-[500px] bg-gradient-to-tr from-primary/30 to-purple-500/30 rounded-full blur-[80px] -z-10 animate-pulse-slow" />

            {/* floating elements background */}
            <FloatingElement delay={0} x="-120px" y="-180px">
                <div className="w-16 h-16 rounded-2xl bg-white/80 backdrop-blur-md shadow-xl flex items-center justify-center border border-white/50">
                    <Shield className="text-emerald-500 w-8 h-8" strokeWidth={1.5} />
                </div>
            </FloatingElement>

            <FloatingElement delay={1} x="140px" y="160px">
                <div className="w-14 h-14 rounded-full bg-amber-100/90 backdrop-blur-md shadow-lg flex items-center justify-center border border-amber-200">
                    <span className="text-2xl">⚡</span>
                </div>
            </FloatingElement>


            {/* THE PHONE CONTAINER */}
            <motion.div
                initial={{ rotateY: -10, rotateX: 5, y: 20, opacity: 0 }}
                animate={{
                    rotateY: [-5, 5, -5],
                    rotateX: [2, -2, 2],
                    y: [0, -15, 0],
                    opacity: 1
                }}
                transition={{
                    rotateY: { duration: 8, repeat: Infinity, ease: "easeInOut" },
                    rotateX: { duration: 10, repeat: Infinity, ease: "easeInOut" },
                    y: { duration: 6, repeat: Infinity, ease: "easeInOut" },
                    opacity: { duration: 0.8 }
                }}
                className="relative w-[300px] h-[580px] bg-gray-900 rounded-[45px] p-3 shadow-2xl border-4 border-gray-800 ring-1 ring-white/20 z-10"
                style={{ transformStyle: "preserve-3d" }}
            >
                {/* Screen Content */}
                <div className="w-full h-full bg-white rounded-[35px] overflow-hidden relative flex flex-col">

                    {/* Status Bar */}
                    <div className="h-8 w-full flex justify-between items-center px-6 pt-2">
                        <span className="text-[10px] font-bold text-gray-800">9:41</span>
                        <div className="flex gap-1">
                            <div className="w-3 h-3 bg-gray-800 rounded-full opacity-20" />
                            <div className="w-3 h-3 bg-gray-800 rounded-full opacity-20" />
                            <div className="w-3 h-3 bg-gray-800 rounded-full" />
                        </div>
                    </div>

                    {/* App Header */}
                    <div className="px-6 pt-2 pb-4">
                        <div className="flex justify-between items-center mb-6">
                            <div className="w-8 h-8 rounded-full bg-gray-100 flex items-center justify-center text-primary font-bold">M</div>
                            <div className="w-8 h-8 rounded-full bg-gray-100 mx-auto" /> {/* Avatar placeholder */}
                            <div className="w-8 h-8 rounded-full bg-gray-100 flex items-center justify-center">🔔</div>
                        </div>

                        {/* Balance Card */}
                        <div className="bg-[#35255e] p-5 rounded-3xl text-white shadow-xl relative overflow-hidden">
                            <div className="absolute top-0 right-0 w-32 h-32 bg-white/5 rounded-full blur-2xl -translate-y-1/2 translate-x-1/2" />

                            <p className="text-white/60 text-xs font-medium mb-1">Total Balance</p>
                            <h3 className="text-3xl font-bold mb-4">₹ 14,250<span className="text-lg opacity-60">.00</span></h3>

                            <div className="flex gap-3">
                                <div className="flex-1 bg-white/10 rounded-xl py-2 flex flex-col items-center justify-center backdrop-blur-sm">
                                    <Zap size={16} className="mb-1" />
                                    <span className="text-[10px]">Send</span>
                                </div>
                                <div className="flex-1 bg-emerald-500 rounded-xl py-2 flex flex-col items-center justify-center shadow-lg">
                                    <div className="bg-white rounded-full p-0.5 mb-1"><div className="w-1 h-1 bg-emerald-500 rounded-full" /></div>
                                    <span className="text-[10px] font-bold">Scan</span>
                                </div>
                                <div className="flex-1 bg-white/10 rounded-xl py-2 flex flex-col items-center justify-center backdrop-blur-sm">
                                    <CreditCard size={16} className="mb-1" />
                                    <span className="text-[10px]">Cards</span>
                                </div>
                            </div>
                        </div>
                    </div>

                    {/* Live Chart Section */}
                    <div className="px-6 py-2">
                        <div className="flex justify-between items-end mb-2">
                            <p className="text-xs font-bold text-gray-500">Weekly Spend</p>
                            <p className="text-xs font-bold text-emerald-500 flex items-center gap-1">
                                <TrendingUp size={12} /> -12% vs last week
                            </p>
                        </div>
                        {/* Animated Bar Chart */}
                        <div className="h-24 flex items-end justify-between gap-2 px-1">
                            {[40, 65, 30, 85, 50, 90, 60].map((h, i) => (
                                <motion.div
                                    key={i}
                                    initial={{ height: 0 }}
                                    animate={{ height: `${h}%` }}
                                    transition={{ duration: 1, delay: i * 0.1, ease: "backOut" }}
                                    className={`w-full rounded-t-sm ${i === 5 ? 'bg-primary' : 'bg-gray-100'}`}
                                />
                            ))}
                        </div>
                    </div>

                    {/* Recent Transactions List */}
                    <div className="flex-1 bg-gray-50 rounded-t-[30px] p-6 pb-0 overflow-hidden relative">
                        <div className="w-12 h-1 bg-gray-200 rounded-full mx-auto mb-6" />

                        <div className="space-y-4">
                            <TransactionItem
                                icon={<Coffee size={18} />}
                                color="bg-orange-100 text-orange-600"
                                name="Starbucks Coffee"
                                time="Today, 9:41 AM"
                                amount="- ₹280"
                                isPositive={false}
                                delay={1.5}
                            />
                            <TransactionItem
                                icon={<ShoppingBag size={18} />}
                                color="bg-blue-100 text-blue-600"
                                name="Zudio Store"
                                time="Yesterday"
                                amount="- ₹1,499"
                                isPositive={false}
                                delay={1.7}
                            />
                            <TransactionItem
                                icon={<div className="font-bold text-xs">M</div>}
                                color="bg-emerald-100 text-emerald-600"
                                name="Cashback Received"
                                time="Instant Reward"
                                amount="+ ₹50"
                                isPositive={true}
                                delay={1.9}
                            />
                        </div>

                        {/* Bottom Fade */}
                        <div className="absolute bottom-0 left-0 right-0 h-16 bg-gradient-to-t from-white to-transparent" />
                    </div>

                </div>
            </motion.div>

        </div>
    );
}

function FloatingElement({ children, x, y, delay }: { children: React.ReactNode, x: string, y: string, delay: number }) {
    return (
        <motion.div
            initial={{ opacity: 0, scale: 0 }}
            animate={{ opacity: 1, scale: 1, y: [0, -10, 0] }}
            transition={{
                scale: { delay, duration: 0.5, type: "spring" },
                y: { delay: delay + 0.5, duration: 4, repeat: Infinity, ease: "easeInOut" }
            }}
            className="absolute z-20"
            style={{ x, y }}
        >
            {children}
        </motion.div>
    );
}

function TransactionItem({ icon, color, name, time, amount, isPositive, delay }: any) {
    return (
        <motion.div
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay, duration: 0.5 }}
            className="flex items-center gap-3"
        >
            <div className={`w-10 h-10 rounded-xl ${color} flex items-center justify-center shrink-0`}>
                {icon}
            </div>
            <div className="flex-1">
                <h4 className="text-sm font-bold text-gray-800">{name}</h4>
                <p className="text-[10px] text-gray-400">{time}</p>
            </div>
            <span className={`text-sm font-bold ${isPositive ? 'text-emerald-500' : 'text-gray-800'}`}>
                {amount}
            </span>
        </motion.div>
    )
}
