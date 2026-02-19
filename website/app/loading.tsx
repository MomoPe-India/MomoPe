export default function Loading() {
    return (
        <div className="min-h-screen bg-white flex items-center justify-center">
            <div className="flex flex-col items-center gap-4">
                <div className="w-12 h-12 border-4 border-gray-100 border-t-[#00C4A7] rounded-full animate-spin" />
                <p className="text-sm font-bold text-gray-400 tracking-wider uppercase animate-pulse">Loading...</p>
            </div>
        </div>
    );
}
