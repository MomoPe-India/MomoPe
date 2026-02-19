"use client";

import { motion } from "framer-motion";
import { TrendingUp, Users, DollarSign, ArrowUpRight, MoreHorizontal } from "lucide-react";

export function DashboardPreview() {
    return (
        <motion.div
            initial={{ opacity: 0, y: 40 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ delay: 0.2, duration: 0.8 }}
            className="relative mx-auto max-w-5xl"
        >
            {/* Browser Frame */}
            <div className="bg-white rounded-xl shadow-2xl overflow-hidden border border-gray-200">
                {/* Browser Header */}
                <div className="bg-gray-50 border-b border-gray-200 px-4 py-3 flex items-center gap-2">
                    <div className="flex gap-1.5">
                        <div className="w-3 h-3 rounded-full bg-red-400"></div>
                        <div className="w-3 h-3 rounded-full bg-yellow-400"></div>
                        <div className="w-3 h-3 rounded-full bg-green-400"></div>
                    </div>
                    <div className="ml-4 bg-white px-3 py-1 rounded-md text-xs text-gray-400 flex-grow max-w-md border border-gray-200">
                        dashboard.momope.com/analytics
                    </div>
                </div>

                {/* Dashboard Content */}
                <div className="p-6 md:p-8 bg-surface">
                    <div className="flex justify-between items-center mb-8">
                        <div>
                            <h2 className="text-2xl font-bold text-secondary">Dashboard</h2>
                            <p className="text-text-secondary">Welcome back, Fresh Mart</p>
                        </div>
                        <div className="flex gap-3">
                            <div className="bg-white px-4 py-2 rounded-lg border border-gray-200 text-sm font-medium">Last 7 Days</div>
                            <div className="bg-primary text-white px-4 py-2 rounded-lg text-sm font-medium">Export Report</div>
                        </div>
                    </div>

                    {/* Stats Grid */}
                    <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
                        <StatCard
                            label="Total Revenue"
                            value="₹45,231"
                            trend="+12.5%"
                            icon={<DollarSign className="text-primary" size={24} />}
                        />
                        <StatCard
                            label="New Customers"
                            value="128"
                            trend="+4.2%"
                            icon={<Users className="text-blue-500" size={24} />}
                        />
                        <StatCard
                            label="Avg. Transaction"
                            value="₹353"
                            trend="+2.1%"
                            icon={<TrendingUp className="text-purple-500" size={24} />}
                        />
                    </div>

                    {/* Chart & List Area */}
                    <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                        {/* Mock Chart */}
                        <div className="lg:col-span-2 bg-white p-6 rounded-xl border border-gray-100 shadow-sm">
                            <div className="flex justify-between mb-6">
                                <h3 className="font-bold text-lg text-secondary">Revenue Overview</h3>
                                <MoreHorizontal className="text-gray-400" />
                            </div>
                            <div className="h-64 flex items-end justify-between gap-2 px-2">
                                {[45, 60, 55, 78, 92, 85, 95].map((h, i) => (
                                    <div key={i} className="w-full bg-primary/10 rounded-t-sm hover:bg-primary/20 transition-colors relative group">
                                        <div
                                            className="absolute bottom-0 w-full bg-primary rounded-t-sm transition-all duration-500"
                                            style={{ height: `${h}%` }}
                                        ></div>
                                        {/* Tooltip */}
                                        <div className="absolute -top-10 left-1/2 -translate-x-1/2 bg-secondary text-white text-xs py-1 px-2 rounded opacity-0 group-hover:opacity-100 transition-opacity whitespace-nowrap">
                                            ₹{h * 150}
                                        </div>
                                    </div>
                                ))}
                            </div>
                            <div className="flex justify-between mt-4 text-xs text-gray-400">
                                <span>Mon</span><span>Tue</span><span>Wed</span><span>Thu</span><span>Fri</span><span>Sat</span><span>Sun</span>
                            </div>
                        </div>

                        {/* Recent Transactions */}
                        <div className="bg-white p-6 rounded-xl border border-gray-100 shadow-sm">
                            <h3 className="font-bold text-lg text-secondary mb-6">Recent Sales</h3>
                            <div className="space-y-4">
                                <TransactionRow name="Rahul K." amount="₹450" time="2m ago" />
                                <TransactionRow name="Sneha P." amount="₹1,200" time="15m ago" />
                                <TransactionRow name="Vikram S." amount="₹85" time="32m ago" />
                                <TransactionRow name="Priya M." amount="₹230" time="1h ago" />
                                <TransactionRow name="Amit B." amount="₹650" time="2h ago" />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </motion.div>
    );
}

function StatCard({ label, value, trend, icon }: { label: string, value: string, trend: string, icon: React.ReactNode }) {
    return (
        <div className="bg-white p-6 rounded-xl border border-gray-100 shadow-sm hover:shadow-md transition-shadow">
            <div className="flex justify-between items-start mb-4">
                <div className="p-3 bg-surface rounded-lg">{icon}</div>
                <div className="flex items-center gap-1 text-green-500 text-sm font-bold bg-green-50 px-2 py-1 rounded-full">
                    <ArrowUpRight size={14} />
                    {trend}
                </div>
            </div>
            <p className="text-text-secondary text-sm mb-1">{label}</p>
            <h3 className="text-2xl font-bold text-secondary">{value}</h3>
        </div>
    );
}

function TransactionRow({ name, amount, time }: { name: string, amount: string, time: string }) {
    return (
        <div className="flex items-center justify-between p-3 hover:bg-surface rounded-lg transition-colors cursor-pointer">
            <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-full bg-primary/10 flex items-center justify-center text-primary font-bold text-sm">
                    {name.charAt(0)}
                </div>
                <div>
                    <p className="font-bold text-secondary text-sm">{name}</p>
                    <p className="text-gray-400 text-xs">{time}</p>
                </div>
            </div>
            <span className="font-bold text-secondary">{amount}</span>
        </div>
    );
}
