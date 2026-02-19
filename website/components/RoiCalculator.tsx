"use client";

import { useState, useEffect } from "react";
import { TrendingUp, Users, Calculator } from "lucide-react";

export function RoiCalculator() {
    const [monthlySales, setMonthlySales] = useState(500000); // 5 Lakhs
    const [ticketSize, setTicketSize] = useState(500);

    // Constants
    const AVG_COMPETITOR_RATE = 0.02;
    const RETENTION_BOOST = 0.30;

    // derived values
    // const competitorFees = ... (unused)
    // const projectedGrowth = ... (unused)

    const annualRevenue = monthlySales * 12;
    const annualGrowth = monthlySales * RETENTION_BOOST * 12;

    return (
        <div className="bg-white rounded-3xl shadow-xl overflow-hidden border border-gray-100">
            <div className="bg-secondary p-8 text-white">
                <div className="flex items-center gap-3 mb-2">
                    <div className="p-2 bg-primary/20 rounded-lg text-primary">
                        <Calculator size={24} />
                    </div>
                    <h3 className="text-2xl font-bold">Growth Calculator</h3>
                </div>
                <p className="text-gray-300">See how much more you earn with loyal customers.</p>
            </div>

            <div className="p-8 grid grid-cols-1 lg:grid-cols-2 gap-12">
                {/* Inputs */}
                <div className="space-y-8">
                    <div>
                        <label className="block text-sm font-bold text-gray-700 mb-3">
                            Monthly Online Sales (₹)
                        </label>
                        <input
                            type="range"
                            min="10000"
                            max="5000000"
                            step="10000"
                            value={monthlySales}
                            onChange={(e) => setMonthlySales(parseInt(e.target.value))}
                            className="w-full h-2 bg-gray-200 rounded-lg appearance-none cursor-pointer accent-primary"
                        />
                        <div className="mt-2 text-3xl font-bold text-secondary">
                            ₹{monthlySales.toLocaleString('en-IN')}
                        </div>
                    </div>

                    <div>
                        <label className="block text-sm font-bold text-gray-700 mb-3">
                            Average Order Value (₹)
                        </label>
                        <input
                            type="range"
                            min="50"
                            max="5000"
                            step="50"
                            value={ticketSize}
                            onChange={(e) => setTicketSize(parseInt(e.target.value))}
                            className="w-full h-2 bg-gray-200 rounded-lg appearance-none cursor-pointer accent-primary"
                        />
                        <div className="mt-2 text-3xl font-bold text-secondary">
                            ₹{ticketSize.toLocaleString('en-IN')}
                        </div>
                    </div>
                </div>

                {/* Results */}
                <div className="bg-surface rounded-2xl p-6 border border-gray-200 relative overflow-hidden">
                    <div className="absolute top-0 right-0 w-32 h-32 bg-primary/10 rounded-full blur-2xl -z-10" />

                    <h4 className="text-lg font-bold text-gray-500 mb-6 uppercase tracking-wider">Projected Annual Impact</h4>

                    <div className="space-y-6">
                        <ResultRow
                            icon={<TrendingUp className="text-green-500" />}
                            label="Extra Revenue (Retention)"
                            value={`+₹${annualGrowth.toLocaleString('en-IN')}`}
                            sub="Based on 30% increase in repeat visits"
                        />
                        <ResultRow
                            icon={<Users className="text-blue-500" />}
                            label="New Loyal Customers"
                            value={`~${Math.floor((monthlySales / ticketSize) * 0.15)}`}
                            sub="Monthly new customers retained"
                        />
                    </div>

                    <div className="mt-8 pt-6 border-t border-gray-200">
                        <div className="flex justify-between items-center mb-2">
                            <span className="font-bold text-secondary">Total Potential Value</span>
                            <span className="text-3xl font-bold text-primary">₹{(annualRevenue + annualGrowth).toLocaleString('en-IN')}</span>
                        </div>
                        <p className="text-xs text-gray-400 text-right">vs ₹{annualRevenue.toLocaleString('en-IN')} standard revenue</p>
                    </div>
                </div>
            </div>
        </div>
    );
}

function ResultRow({ icon, label, value, sub }: { icon: React.ReactNode, label: string, value: string, sub: string }) {
    return (
        <div className="flex items-start gap-4">
            <div className="p-3 bg-white rounded-xl shadow-sm border border-gray-100">
                {icon}
            </div>
            <div>
                <div className="text-sm font-bold text-gray-600 mb-1">{label}</div>
                <div className="text-2xl font-bold text-secondary mb-1">{value}</div>
                <div className="text-xs text-gray-400">{sub}</div>
            </div>
        </div>
    );
}
