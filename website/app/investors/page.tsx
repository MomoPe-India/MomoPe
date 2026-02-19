import type { Metadata } from "next";
import { InvestorsContent } from "@/components/InvestorsContent";

export const metadata: Metadata = {
    title: "Investor Relations",
    description: "MomoPe is unlocking the $1.2T offline commerce market in India. Explore our 10-year roadmap, unit economics, and growth strategy.",
    openGraph: {
        title: "Invest in MomoPe | The Future of Local Commerce",
        description: "Building the engagement layer for 60M+ Indian merchants. Profitable unit economics from Day 1.",
    }
};

export default function InvestorsPage() {
    return <InvestorsContent />;
}
