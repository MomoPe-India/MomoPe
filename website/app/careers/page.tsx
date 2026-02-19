import type { Metadata } from "next";
import { CareersContent } from "@/components/CareersContent";

export const metadata: Metadata = {
    title: "Careers at MomoPe",
    description: "Join the team building the Financial OS for local India. We value ownership, speed, and customer obsession. Open roles in Engineering & Sales.",
    openGraph: {
        title: "Join the Revolution | MomoPe Careers",
        description: "We don't build features; we solve problems. Check out open roles in Bangalore and Remote.",
    }
};

export default function CareersPage() {
    return <CareersContent />;
}
