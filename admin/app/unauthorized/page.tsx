export default function UnauthorizedPage() {
    return (
        <div className="min-h-screen flex items-center justify-center bg-[#0B0F19]">
            <div className="text-center max-w-sm px-6">
                <div className="w-16 h-16 mx-auto mb-6 rounded-2xl bg-red-500/10 border border-red-500/20 flex items-center justify-center">
                    <svg className="w-8 h-8 text-red-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5}
                            d="M12 9v3.75m-9.303 3.376c-.866 1.5.217 3.374 1.948 3.374h14.71c1.73 0 2.813-1.874 1.948-3.374L13.949 3.378c-.866-1.5-3.032-1.5-3.898 0L2.697 16.126zM12 15.75h.007v.008H12v-.008z" />
                    </svg>
                </div>
                <h1 className="text-2xl font-bold text-white mb-2">Access Denied</h1>
                <p className="text-slate-400 text-sm leading-relaxed mb-6">
                    Your account does not have admin privileges. Contact the system owner to request access.
                </p>
                <a
                    href="/login"
                    className="inline-flex items-center gap-2 px-5 py-2.5 rounded-xl bg-white/[0.06] text-slate-300 text-sm font-medium hover:bg-white/[0.10] transition-colors border border-white/[0.08]"
                >
                    ← Back to Login
                </a>
            </div>
        </div>
    )
}
