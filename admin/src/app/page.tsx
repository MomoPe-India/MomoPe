// src/app/page.tsx — redirect root to dashboard
import { redirect } from 'next/navigation';
export default function RootPage() { redirect('/dashboard'); }
