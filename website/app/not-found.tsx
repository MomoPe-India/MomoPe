import Link from 'next/link';
import { ArrowLeft } from 'lucide-react';

export default function NotFound() {
    return (
        <div className="min-h-screen bg-gray-50 flex flex-col items-center justify-center text-center px-6">
            <h2 className="text-9xl font-bold text-gray-200">404</h2>
            <h1 className="text-3xl font-bold text-[#35255e] mt-4 mb-4">Page Not Found</h1>
            <p className="text-gray-500 mb-8 max-w-md">
                Oops! The page you are looking for does not exist. It might have been moved or deleted.
            </p>
            <Link
                href="/"
                className="px-8 py-3 bg-[#00C4A7] text-white rounded-xl font-bold hover:bg-[#00A890] transition-colors flex items-center gap-2"
            >
                <ArrowLeft size={20} /> Back to Home
            </Link>
        </div>
    );
}
