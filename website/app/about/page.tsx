import type { Metadata } from "next";
import { AboutContent } from "@/components/AboutContent";

export const metadata: Metadata = {
    title: "About Us | Our Vision",
    description: "MomoPe is on a mission to revolutionize local commerce. Learn about our values, our 10-year roadmap, and the team behind the platform.",
};

export default function AboutPage() {
    return <AboutContent />;
}
